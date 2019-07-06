#################################
# 土砂災害・雪崩メッシュデータ
# Source: 国土交通省 国土数値情報 (A05)
# http://nlftp.mlit.go.jp/ksj/gml/datalist/KsjTmplt-A30a5.html
# prefectureName
# cityName
# hazardDate
# hazardType
# maxRainfallFor_24h
# maxRainfall_h
# inclination...
# 事後的な変数
### ... 11 variables
# Subset: 九州地方
#################################
library(dplyr)
library(sf)
library(assertr)
library(ensurer)
library(ggplot2)
source("https://gist.githubusercontent.com/uribo/5c67ef24dcaf17402175b0d474cd8cb2/raw/0136636eab1ac905e019189e775c75bd20efb523/ksj_parse_a30a5.R")

# 1. ksjからのデータ取得 ----------------------------------------------------------
plan_hazard_mesh <- drake::drake_plan(
  dl_files = 
    if (rlang::is_false(file.exists(here::here("data-raw/hazard.csv")))) {
    # path <- "~/Documents/resources/国土数値情報/A30a5/A30a5-11_5637-jgd_GML/A30a5-11_5637_SedimentDisasterAndSnowslide.shp"
    # 
    # df_hazard5637 <-
    #   ksj_parse_a30a5(path)
    # 
    # df_hazard5637 %>%
    #   st_drop_geometry() %>%
    #   mutate(date_m = lubridate::round_date(hazardDate, unit = "month")) %>%
    #   count(date_m, sort = TRUE) %>%
    #   ggplot(aes(date_m, n)) +
    #   geom_bar(stat = "identity")
    # 
    # df_hazard5637 %>%
    #   st_drop_geometry() %>%
    #   ggplot(aes(maxRainfallFor_24h, outflowSediment_m3, color = hazardType)) +
    #   geom_point()
    
    # files <-fs::dir_ls("~/Downloads/A30a5/", regexp = ".zip")
    # files %>% 
    #   purrr::walk(
    #     ~ unzip(zipfile = .x,
    #             exdir = paste0("~/Documents/resources/国土数値情報/A30a5/",
    #                            stringr::str_remove(basename(.x), ".zip"))
    #   ))
    },
    df_hazard =
      fs::dir_ls(here::here("data-raw/A30a5"),
                 recurse = TRUE,
                 regexp = ".shp") %>%
      ensure(length(.) == 106L) %>% 
      purrr::map(
        ksj_parse_a30a5
      ) %>%
      purrr::reduce(rbind) %>% 
      verify(dim(.) == c(4315, 11)) %>% 
      st_transform(crs = 4326) %>% 
      st_drop_geometry() %>%
      tidyr::extract(hazardType,
                     into = c("hazardType_", "hazardType_sub"), regex = "(.+)(\\(.+\\))",
                     remove = FALSE) %>%
      mutate(hazardType_ = if_else(is.na(hazardType_), hazardType, hazardType_)) %>%
      select(-hazardType) %>%
      rename(hazardType = hazardType_) %>% 
    tidyr::extract(hazardType_sub, "hazardType_sub") %>% 
    mutate(hazardType = stringr::str_remove(hazardType, "\\(.+")),
    df_hazard %>% 
      write_csv(here::here("data-raw/hazard.csv"))#,
  # df_hazard = 
  #   read_csv(here::here("data-raw/hazard.csv"),
  #            col_types = cols(
  #              prefectureName = col_character(),
  #              cityName = col_character(),
  #              hazardDate = col_date(format = ""),
  #              hazardType = col_character(),
  #              hazardType_sub = col_character(),
  #              maxRainfallFor_24h = col_double(),
  #              maxRainfall_h = col_double(),
  #              inclination = col_character(),
  #              outflowSediment_m3 = col_double(),
  #              landslideLength_m = col_double(),
  #              meshCode = col_character()
  #            )) %>% 
  # jpmesh::meshcode_sf(meshCode)
)
drake::make(plan_hazard_mesh, packages = c("dplyr", "sf", "readr"))
drake::loadd(plan_hazard_mesh, list = c("df_hazard"))

# subset ----------------------------------------------------------------------
library(lubridate)
library(jpmesh)
library(jmastats)
library(rnaturalearth)
source("https://gist.githubusercontent.com/uribo/80a94a911b5cc81e5182809f2f8da7a0/raw/12b3269f1fa9cccfdfdda47ea17cd4d1526e353a/jgd2011.R")
parse_jma_obsdl <- function(path, convert = TRUE) {
  name_stations_raw <- 
    names(suppressWarnings(readr::read_csv(path,
                                           locale = readr::locale(encoding = "cp932"),
                                           skip = 2,
                                           n_max = 1))) %>%
    .[-1] %>% 
    stringr::str_remove("_.+")
  name_st <- 
    c("date",
      paste(name_stations_raw,
            names(suppressWarnings(readr::read_csv(path,
                                                   locale = readr::locale(encoding = "cp932"),
                                                   skip = 3,
                                                   n_max = 1))) %>% 
              .[-1],
            sep = "_"))
  d <- 
    suppressWarnings(readr::read_csv(path,
                                     locale = readr::locale(encoding = "cp932"),
                                     skip = 4,
                                     col_types = paste0(rep("c", times = length(name_st)), collapse = ""))) %>% 
    purrr::set_names(name_st)
  remove_cols <- 
    d %>%
    slice(1L) %>%
    tidyr::gather() %>%
    mutate(col_id = row_number()) %>%
    filter(value %in% c("現象なし情報", "品質情報", "均質番号")) %>%
    pull(col_id)
  d <- 
    d %>%
    slice(-1L) %>%
    select(-remove_cols) %>% 
    tidyr::gather(key, value, -date) %>%
    mutate(date = lubridate::ymd(date),
           station_name = stringr::str_remove(key, "_.+"),
           key = stringr::str_remove(key, paste0(station_name, "_")) %>% 
             stringr::str_remove("_.+")) %>%
    mutate(station_name = forcats::as_factor(station_name) %>% 
             forcats::fct_inorder(),
           key = case_when(
             key == "降水量の合計(mm)" ~ "precipitation_sum(mm)",
             key == "1時間降水量の最大(mm)" ~ "precipitation_max_1hour(mm)")) %>% 
    group_by(date, station_name) %>% 
    mutate(.row = row_number()) %>% 
    tidyr::spread(key, value) %>%
    tidyr::fill(`precipitation_max_1hour(mm)`, .direction = "up") %>% 
    select(-.row) %>% 
    slice(1L) %>% 
    ungroup() %>% 
    readr::type_convert() %>%
    arrange(station_name, date) %>% 
    mutate(station_name = as.character(station_name))
  
  if (rlang::is_true(convert))
    d <- d %>% 
    jmastats:::convert_variable_unit()
  
  d
}

plan_hazard_subset <- drake::drake_plan(
  df_hazard_kyusyu200607 = 
    df_hazard %>% 
    filter(!is.na(hazardDate),
           prefectureName %in% c("鹿児島県", "熊本県", "長崎県", "宮崎県", 
                                 "大分県", "佐賀県", "福岡県")) %>% 
    select(hazardDate, meshCode, hazardType) %>% 
    st_drop_geometry() %>% 
    distinct(hazardDate, meshCode, .keep_all = TRUE) %>% 
    tidyr::complete(hazardDate = tidyr::full_seq(hazardDate, 1)) %>% 
    filter(between(hazardDate, ymd("2006-07-01"), ymd("2006-07-31"))) %>% 
    filter(!is.na(meshCode)) %>% 
    transmute(hazardDate,
              meshCode,
              hazard = if_else(is.na(hazardType), FALSE, TRUE)) %>% 
    verify(expr = dim(.) == c(214, 3)),
  ne_kyusyu =
    ne_states(country = "Japan", returnclass = "sf") %>% 
    tibble::new_tibble(nrow = nrow(.), subclass = "sf") %>% 
    select(gn_name) %>% 
    right_join(jpndistrict::jpnprefs %>% 
                 filter(major_island_en == "Kyushu") %>% 
                 select(contains("prefecture")),
               by = c("gn_name" = "prefecture_en")) %>% 
    select(-gn_name) %>% 
    verify(expr = dim(.) == c(7, 2)),
  station_kys =
    stations %>% 
    filter(pref_code %in% c(seq.int(40, 46))) %>% 
    select(station_name, station_no, station_type, block_no, pref_code) %>% 
    verify(nrow(.) == 169),
  df_kyusyu_weather_200607 =
    fs::dir_ls(here::here("data-raw"), regexp = "jma_200607_pref.+.csv") %>%
    purrr::map_dfr(
      parse_jma_obsdl, convert = FALSE),
  sf_kyusyu_5km_meshes =
    jpmesh::sf_jpmesh %>% 
    st_join(ne_kyusyu) %>% 
    filter(!is.na(prefecture)) %>% 
    pull(meshcode) %>%
    purrr::map(fine_separate) %>% 
    purrr::reduce(c) %>% 
    unique() %>% 
    purrr::map(
      ~ paste0(.x, seq.int(1, 4))
    ) %>% 
    purrr::reduce(c) %>%
    export_meshes() %>% 
    st_join(st_sf(st_union(ne_kyusyu)), 
            join = st_intersects, 
            left = FALSE) %>% 
    sample_n(500),
  df_hazard_kys200607 = 
    sf_kyusyu_5km_meshes %>% 
    st_drop_geometry() %>% 
    tidyr::expand(hazardDate = tidyr::full_seq(seq(ymd(20060701), 
                                                   ymd(20060731), 1), 1), 
                  meshcode) %>% 
    mutate(hazard = FALSE) %>% 
    rename(meshCode = meshcode) %>% 
    anti_join(df_hazard_kyusyu200607, 
              by = c("hazardDate", "meshCode", "hazard")) %>% 
    sample_n(2000) %>% 
    bind_rows(df_hazard_kyusyu200607) %>% 
    arrange(hazardDate, meshCode) %>% 
    jpmesh::meshcode_sf(meshCode) %>% 
    verify(expr = dim(.) == c(2214, 4)),
  station_kys_5kmmesh =
    df_hazard_kys200607 %>% 
    distinct(meshCode) %>% 
    st_transform(crs = 6668) %>% 
    verify(nrow(.) == 630) %>% 
    mutate(nearest_station_no = purrr::pmap_int(.,
                                                ~ nearest_station(
                                                  geometry = st_centroid(..2)) %>%
                                                  pull(station_no) %>% 
                                                  .[1]),
           distance = purrr::pmap_dbl(.,
                                      ~ nearest_station(
                                        geometry = st_centroid(..2)) %>%
                                        pull(distance) %>% 
                                        .[1])) %>% 
    st_transform(crs = 4326) %>% 
    left_join(station_kys %>% 
                st_drop_geometry(),
              by = c("nearest_station_no" = "station_no")) %>% 
    arrange(meshCode, distance) %>% 
    group_by(meshCode) %>% 
    slice(1L) %>% 
    ungroup() %>% 
    verify(expr = nrow(.) == 630L),
  df_hazard_kys =
    df_hazard_kys200607 %>%
    verify(nrow(.) == 2214) %>%
    left_join(station_kys_5kmmesh %>% 
                st_drop_geometry(),
              by = "meshCode") %>%
    verify(nrow(.) == nrow(df_hazard_kys200607)) %>%
    left_join(df_kyusyu_weather_200607,
              by = c("hazardDate" = "date",
                     "station_name")) %>%
    jmastats:::convert_variable_unit() %>% 
    verify(dim(.)  == c(2214, 12))
  )
drake::make(plan_hazard_subset)
# drake::loadd(list = plan_hazard_subset$target)
drake::loadd(plan_hazard_subset, list = c(
  "station_kys_5kmmesh",
  "df_hazard_kys"))

source("https://gist.githubusercontent.com/uribo/5c67ef24dcaf17402175b0d474cd8cb2/raw/321ab20ec6485193889989b5a50b48af080fb9bb/ksj_parse_g04.R")
source("https://gist.githubusercontent.com/uribo/5c67ef24dcaf17402175b0d474cd8cb2/raw/321ab20ec6485193889989b5a50b48af080fb9bb/ksj_parse_a23.R")
# 土壌、地形
plan_kyusyu_land_soil <- drake::drake_plan(
  df_ksj_a23 =
    fs::dir_ls(here::here("data-raw/A23/"),
               recurse = TRUE,
               regexp = paste0("(",
                               paste0(seq.int(40, 46), collapse = "|"),
                               ").shp$")) %>% 
    purrr::map(ksj_parse_a23) %>% 
    purrr::reduce(rbind) %>% 
    select(9) %>% 
    purrr::set_names(c("particularSoilTypeCode", "geometry")) %>% 
    group_by(particularSoilTypeCode) %>% 
    summarise() %>% 
    left_join(
      df_particularSoilTypeCode,
      by = "particularSoilTypeCode") %>% 
    assertr::verify(nrow(.) == 5L),
  df_ksj_g04mesh1km = fs::dir_ls(here::here("data-raw/G04a"),
                                 regexp = paste0("G04-a-11_(",
                                                 paste(df_hazard_kys %>% 
                                                         pull(meshCode) %>% 
                                                         unique() %>% 
                                                         stringr::str_sub(1, 4) %>% 
                                                         unique() %>% 
                                                         ensurer::ensure(length(.) == 22L),
                                                       collapse = "|"),
                                                 ")-jgd_GML/.+.shp"),
                                 recurse = TRUE) %>% 
    purrr::map(ksj_parse_g04) %>% 
    purrr::reduce(rbind) %>% 
    filter(stringr::str_detect(meshcode,
                               paste0("^(",
                                      df_hazard_kys %>% 
                                        pull(meshCode) %>% 
                                        unique() %>% 
                                        paste(collapse = "|"),
                                      ")"))),
  land_vars = stringr::str_subset(names(df_ksj_g04mesh1km), "(meshcode|geometry)", negate = TRUE),
  df_kys_5kmmesh_land = 
    station_kys_5kmmesh %>%
    select(meshCode) %>%
    st_join(df_ksj_g04mesh1km %>% 
              select(-meshcode)) %>%
    st_drop_geometry() %>%
    # 5kmメッシュ内の1kmメッシュ平均値 (最大で25の1kmメッシュ)
    group_by(meshCode) %>%
    summarise_if(is.numeric, mean, na.rm = TRUE) %>% 
    mutate_if(is.numeric,
              .funs = list(~ if_else(is.nan(.), NA_real_, .))) %>% 
    verify(dim(.) == c(630, 10)),
  # df_kys_5kmmesh_land =
  #   station_kys_5kmmesh %>%
  #   select(meshCode) %>%
  #   st_join(df_ksj_g04mesh1km) %>%
  #   st_drop_geometry() %>%
  #   group_by(meshCode) %>%
  #   mutate_if(is.numeric,
  #             .funs = list(~ if_else(is.na(.),
  #                                    mean(., na.rm = TRUE),
  #                                    .))) %>%
  #   mutate(mesh_id = row_number()) %>%
  #   ungroup() %>%
  #   select(-meshcode) %>%
  #   tidyr::pivot_wider(names_from = mesh_id,
  #                      values_from = c(mean_elevation, max_elevation, min_elevation,
  #                                      minimum_elevation_code,
  #                                      max_slope_aspect, max_slope_angle,
  #                                      min_slope_aspect, min_slope_angle, mean_slope_aspect),
  #                      names_prefix = "mesh") %>% 
  #   verify(dim(.) == c(630, 226)),
    df_hazard_kys_lands =
      df_hazard_kys %>%
      mutate(soil_type1 = st_intersects(geometry,
                                        df_ksj_a23 %>%
                                          filter(particularSoilTypeCode == 1),
                                        sparse = FALSE)[,1],
             soil_type2 = st_intersects(geometry,
                                        df_ksj_a23 %>%
                                          filter(particularSoilTypeCode == 2),
                                        sparse = FALSE)[,1],
             soil_type5 = st_intersects(geometry,
                                        df_ksj_a23 %>%
                                          filter(particularSoilTypeCode == 5),
                                        sparse = FALSE)[,1],
             soil_type6 = st_intersects(geometry,
                                        df_ksj_a23 %>%
                                          filter(particularSoilTypeCode == 6),
                                        sparse = FALSE)[,1],
             soil_type8 = st_intersects(geometry,
                                        df_ksj_a23 %>%
                                          filter(particularSoilTypeCode == 8),
                                        sparse = FALSE)[,1]) %>%
      select(everything(), geometry) %>%
      left_join(df_kys_5kmmesh_land, by = "meshCode") %>% 
    mutate(longitude = sf::st_coordinates(st_centroid(geometry))[, 1],
           latitude = sf::st_coordinates(st_centroid(geometry))[, 2]) %>% 
    #verify(dim(.) == c(2214, 244)),
    verify(dim(.) == c(2214, 28)),
  df_hazard_kys_lands %>%
    st_drop_geometry() %>%
    write_csv("data-raw/hazard_kyusyu201607.csv")
  )
drake::make(plan_kyusyu_land_soil)
# drake::loadd(list = plan_kyusyu_land_soil$target)
# drake::loadd(list = c("df_hazard_kys_lands", "land_vars"))
drake::loadd(plan_kyusyu_land_soil, list = c("df_hazard_kys_lands", "land_vars"))
