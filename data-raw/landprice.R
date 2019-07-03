################################
# 地価データ
# Source: 国土交通省 国土数値情報 (L01)
#　http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L01-v2_5.html
# Subset: 関東一都六県 (landprice_kanto.csv)
# pkgs --------------------------------------------------------------------
library(dplyr)
library(sf)
library(drake)
source("https://gist.githubusercontent.com/uribo/5c67ef24dcaf17402175b0d474cd8cb2/raw/f22325491942e8e1ebf82ad04fdd1881c468a606/ksj_parse_l01.R") # ksj_parse_l01
plan_land_price_raw <- 
  drake_plan(
    predict_vars = rlang::quo(
      c(index_number,
        sequence_number,
        administrative_area_code,
        posted_land_price,
        name_of_nearest_station,
        distance_from_station, 
        acreage,
        current_use,
        usage_description,
        building_structure,
        ends_with("facility"), # ~~proximity_with_transportation_facility はあとで除外する~~
        depth_ratio,
        starts_with("number_of"),
        use_district,  # factor
        building_coverage, 
        configuration,
        surrounding_present_usage,
        fire_area,
        urban_planning_area,
        forest_law,
        parks_law,
        ends_with("ratio"),
        # ends_with("Road"),
        starts_with("attribute_change"),
        common_surveyed_position,
        longitude,
        latitude)),
    ksj_l01_download = {
      if (rlang::is_false(file.exists(here::here("data-raw/L01-18_00_GML/")))) {
        # 2018年 全国のデータをダウンロード
        # areaCode == 0 は全国
        dl_url <- 
          kokudosuuchi::getKSJURL(identifier = "L01") %>% 
          filter(year == 2018, areaCode == 0) %>% 
          pull(zipFileUrl) %>% 
          ensurer::ensure(length(.) == 1L)
        dl_url %>% 
          download.file(destfile = here::here("data-raw", basename(dl_url)))
        dir.create(here::here("data-raw", gsub(".zip", "", basename(dl_url))))
        unzip(here::here("data-raw", basename(dl_url)),
              exdir = here::here("data-raw"))
        unlink(here::here("data-raw", basename(dl_url)))
      }
    },
    # 全国
    df_landprice = 
      ksj_parse_l01(here::here("data-raw/L01-18_00_GML/L01-18.geojson")) %>% 
      assertr::verify(dim(.) == c(25988, 127)) %>% 
      # 56, 92
      select(-num_range("L01_", seq.int(55, 126), width = 3)) %>% 
      # 列名は茨城県のデータから用意する（構造は同じ）
      set_names_l01(xml_path = here::here("data-raw/L01-18_08_GML/L01-18_08.xml")) %>% 
      janitor::clean_names() %>% 
      assertr::verify(ncol(.) == 55L))
drake::make(plan_land_price_raw)
drake::loadd(plan_land_price_raw, 
             list = c("predict_vars", "df_landprice"))

plan_land_price <- 
  drake_plan(
    df_landprice_mod = 
      df_landprice %>% 
      mutate(latitude = sf::st_coordinates(geometry)[, 2],
             longitude = sf::st_coordinates(geometry)[, 1]) %>% 
      sf::st_drop_geometry() %>% 
      readr::type_convert() %>% 
      mutate_if(is.factor, list(~ na_if(., "_"))) %>% 
      select(!!predict_vars) %>% 
      # select(-proximity_with_transportation_facility) %>% 
      # mutate(use_district = forcats::as_factor(use_district)) %>% 
      tibble::rowid_to_column(var = "row_id") %>% 
      # tidyr::separate_rows(current_use, sep = ",") %>% 
      # add_count(row_id) %>%
      # ungroup() %>% 
      rename(.row_id = row_id,
             .index_number = index_number,
             .sequence_number = sequence_number,
             .longitude = longitude,
             .latitude = latitude) %>% 
      assertr::verify(data = ., expr = dim(.) == c(25988, 45)),
    df_landprice_mod %>% 
      readr::write_csv(here::here("data-raw/landprice.csv")),
    incomplete_vars =
      df_landprice_mod %>% 
      naniar::miss_var_summary() %>% 
      filter(n_miss > 0) %>% 
      pull(variable) %>% 
      ensurer::ensure_that(length(.) == 8)
  )
drake::make(plan_land_price)
drake::loadd(plan_land_price,
             list = c("df_landprice_mod", "incomplete_vars"))


# 関東一都六県 ------------------------------------------------------------------
source("https://gist.githubusercontent.com/uribo/40a0e67b9625062e816defabb88f8656/raw/ca7afaee9ed9f68f2e29862230bacff2f5f87e36/subset_kanto_citycode.R")
plan_lp_subset <- 
  drake_plan(
    # 夜間人口 --------------------------------------------------------------------
    # https://www.e-stat.go.jp/stat-search/files?page=1&layout=datalist&toukei=00200521&tstat=000001080615&cycle=0&tclass1=000001101935&tclass2=000001101936&cycle_facet=tclass1%3Acycle
    
    if (file.exists(here::here("data-raw/001_00.csv")) == FALSE) {
      download.file("https://www.e-stat.go.jp/stat-search/file-download?statInfId=000031586670&fileKind=1",
                    destfile = here::here("data-raw/001_00.csv"))  
    },
    df_night_population = 
      readr::read_csv(here::here("data-raw/001_00.csv"), 
                      locale = readr::locale(encoding = "cp932"),
                      skip = 14,
                      col_names = c("jis_code", "night_population"),
                      col_types = c("__c__d_________________________________________")),
    df_lp_kanto = 
      df_landprice_mod %>% 
      mutate(administrative_area_code = as.character(administrative_area_code)) %>% 
      subset_kanto_citycode(administrative_area_code) %>%
      mutate(pref_code = stringr::str_sub(administrative_area_code, 1, 2),
             .prefecture = case_when(
               pref_code == "08" ~ "茨城県",
               pref_code == "09" ~ "栃木県",
               pref_code == "10" ~ "群馬県",
               pref_code == "11" ~ "埼玉県",
               pref_code == "12" ~ "千葉県",
               pref_code == "13" ~ "東京都",
               pref_code == "14" ~ "神奈川県")) %>% 
  select(-pref_code, -.index_number, -.sequence_number) %>%
    left_join(df_night_population, 
              by = c("administrative_area_code" = "jis_code")) %>% 
  select(.row_id, .prefecture, everything()) %>% 
  assertr::verify(data = ., expr = nrow(.) == 8476L),
    df_lp_kanto %>% 
      readr::write_csv(here::here("data-raw/landprice_kanto.csv")))
drake::make(plan_lp_subset)
drake::loadd(plan_lp_subset, list = c("df_lp_kanto"))
