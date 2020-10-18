################################
# 地価データ
# Source: 国土交通省 国土数値情報 (L01) 平成30年 (2018)
#　https://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-L01-v2_5.html
# Subset: 関東一都六県 (landprice_kanto.csv)
# 地積: acreage
# 駅からの距離: distance_from_station
# 利用現況: current_use (住宅、店舗、事務所、銀行、旅館、給油所、工場、倉庫、農地、山林、医院、空地、作業場、原野、その他、用材、雑木)
# 用途区分: use_district
# 建物構造: building_structure
# SRC：鉄骨・鉄筋コンクリート
# RC：鉄筋コンクリート
# S：鉄骨造
# LS：軽量鉄骨造
# B：ブロック造
# W：木造
# 「建物構造略号」＋「建物の階数」で示す。ただし、建物に地下階層がある場合は、地上階数の後に「F」、地下階数の後に「B」を記述する
# pkgs --------------------------------------------------------------------
library(dplyr)
library(sf)
library(drake)

set_names_l01 <- function(data, xml_path) {
  x <-
    xml2::read_xml(xml_path) %>%
    xml2::as_list()
  data %>%
    purrr::set_names(
      c(
        x$Dataset$LandPrice$representedLandCode$RepresentedLandCode %>% names(),
        paste0("previous_", x$Dataset$LandPrice$previousRepresentedLandCode$RepresentedLandCode %>% names()),
        names(x$Dataset$LandPrice[3]),
        names(x$Dataset$LandPrice[5]),
        paste0("attribute_change_", x$Dataset$LandPrice$attributeChange$AttributeChange %>% names()),
        names(x$Dataset$LandPrice[7:40]),
        "geometry"))
}

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
      kuniumi::read_ksj_l01(here::here("data-raw/L01-18_00_GML/L01-18.geojson")) %>% 
      assertr::verify(dim(.) == c(25988, 127)) %>% 
      # 56, 92
      #select(-num_range("L01_", seq.int(55, 126), width = 3)) %>% 
      select(1:54) %>% 
      # select(1, 2, 21, 6, 
      #        45, 46, 24, 25, 26, 27,
      #        12,
      #        28, 29, 30, 43,
      #        33,
      #        34, 35, 47, 52,
      #       31,
      #       44, 48, 49, 50, 51,
      #       20,
      #       32,
      #       53, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19
      #        ) %>% 
      # 列名は茨城県のデータから用意する（構造は同じ）
      set_names_l01(xml_path = here::here("data-raw/L01-18_08_GML/L01-18_08.xml")) %>% 
      janitor::clean_names() %>% 
      assertr::verify(ncol(.) == 55L))
drake::make(plan_land_price_raw)
drake::loadd(list = c("predict_vars", "df_landprice"))

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
drake::loadd(list = c("df_landprice_mod", "incomplete_vars"))

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
drake::loadd(list = c("df_lp_kanto"))
