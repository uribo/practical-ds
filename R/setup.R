source(here::here("R/core_pkgs.R"))
# source(here::here("R/data-converter.R"))
source(here::here("R/step_stri_trans.R"))
source("https://gist.githubusercontent.com/uribo/bc5df991469c8024cc3db78aa669df7a/raw/ac177741ea185292b38c0a00cf9b1bfb052321ae/ds_view.R")

# lp... prep_landprice.R

plan_datasetup <- 
  drake::drake_plan(
    # df_lp = 
    #   read_csv(here::here("data-raw/landprice.csv"),
    #                   col_types = c("icccicddcclllldiicdcccclddclllllllllllldd")),
  df_lp_kanto = 
    read_csv(here::here("data-raw/landprice_kanto.csv"),
                    col_types = 
                      cols(.row_id = "i",
                           .prefecture = "c",
                           administrative_area_code = "c",
                           posted_land_price = "i",
                           name_of_nearest_station = "c",
                           distance_from_station = "i",
                           acreage = "i",
                           current_use = "c",
                           usage_description = "c",
                           building_structure = "c",
                           attribute_change_supplied_facility = "l",
                           water_facility = "l",
                           gas_facility = "l",
                           sewage_facility = "l",
                           proximity_with_transportation_facility = "c",
                           depth_ratio = "d",
                           number_of_floors = "i",
                           number_of_basement_floors = "i",
                           use_district = "c",
                           building_coverage = "d",
                           configuration = "c",
                           surrounding_present_usage = "c",
                           fire_area = "c",
                           urban_planning_area = "c",
                           forest_law = "c",
                           parks_law = "c",
                           attribute_change_floor_area_ratio = "l",
                           frontage_ratio = "d",
                           floor_area_ratio = "d",
                           attribute_change_selected_land_status = "d", # cだったけど変更
                           attribute_change_address = "l",
                           attribute_change_acreage = "l",
                           attribute_change_current_use = "l",
                           attribute_change_building_structure = "l",
                           attribute_change_distance_from_station = "l",
                           attribute_change_use_district = "l",
                           attribute_change_fire_area = "l",
                           attribute_change_urban_planning_area = "l",
                           attribute_change_forest_law = "l",
                           attribute_change_parks_law = "l",
                           attribute_change_building_coverage = "l",
                           common_surveyed_position = "l",
                           night_population = "d",
                           .longitude = "d", 
                           .latitude = "d")) %>% 
    verify(dim(.) == c(8476, 45)),
  df_hazard = 
    read_csv(here::here("data-raw/hazard.csv"),
                    col_types = cols(
                      prefectureName = col_character(),
                      cityName = col_character(),
                      hazardDate = col_date(format = ""),
                      hazardType = col_character(),
                      hazardType_sub = col_character(),
                      maxRainfallFor_24h = col_double(),
                      maxRainfall_h = col_double(),
                      inclination = col_character(),
                      outflowSediment_m3 = col_double(),
                      landslideLength_m = col_double(),
                      meshCode = col_character()
                    )) %>% 
    jpmesh::meshcode_sf(meshCode),
  df_hazard_kys = 
    readr::read_csv(here::here("data-raw/hazard_kyusyu201607.csv"),
                    col_types = c("Dclccccdcddlllllddddddddddd")) %>% 
    verify(dim(.) == c(2214, 27)),
  sf_hazard_kys = 
    df_hazard_kys %>% 
    jpmesh::meshcode_sf(meshCode),
  df_beer = 
    read_csv(here::here("data-raw/beer.csv")) %>% 
    assertr::verify(dim(.) == c(48, 14)),
  df_beer2018q2 = 
    read_csv(here::here("data-raw/beer2018q2.csv"),
             col_types = c("Ddcddddd")) %>% 
    assertr::verify(dim(.) == c(92, 8)),
  ne_jpn =
    rnaturalearth::ne_states(country = "Japan", returnclass = "sf") %>% 
    tibble::new_tibble(nrow = nrow(.), subclass = "sf") %>% 
    select(iso_3166_2, gn_name),
  ne_knt = 
    ne_jpn %>% 
    right_join(jpndistrict::jpnprefs %>% 
                 filter(region_en == "Kanto") %>% 
                 select(contains("prefecture")),
               by = c("gn_name" = "prefecture_en")) %>% 
    select(-gn_name) %>% 
    st_crop(st_as_sfc("POLYGON ((138.3500 34.84700, 138.3500 37.187, 141.0700 37.187, 141.0700 34.84700, 138.3500 34.84700))",
                      crs = 4326)),
  ne_kys =
    ne_jpn %>% 
    select(gn_name) %>% 
    right_join(jpndistrict::jpnprefs %>% 
                 filter(major_island_en == "Kyushu") %>% 
                 select(contains("prefecture")),
               by = c("gn_name" = "prefecture_en")) %>% 
    select(-gn_name))
drake::make(plan_datasetup)
drake::loadd(plan_datasetup,
             list = c(
               #"df_lp", 
                      "df_lp_kanto", 
                      "df_hazard", "df_hazard_kys", "sf_hazard_kys",
                      "df_beer", "df_beer2018q2",
                      "ne_jpn", "ne_knt", "ne_kys"))

knitr::opts_chunk$set(echo = TRUE,
                      eval = FALSE)

# df_hazard %>% 
#   group_by(hazardType, meshCode) %>% 
#   summarise(n = n()) %>% 
#   ungroup() %>% 
#   mapview::mapview(zcol = "n")
