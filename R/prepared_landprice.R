source(here::here("R/setup.R"))

plan_cleaning <- drake::drake_plan(
  df_lp_kanto_clean1 = 
    df_lp_kanto %>%
    select(-.row_id, -.prefecture) %>% 
    # ref) http://www.mlit.go.jp/common/001204008.pdf を元に
    # 1. configurationがNAのものを「四角形」として処理
    mutate(configuration = replace_na(configuration, "四角形")) %>% 
    mutate_at(vars(fire_area, forest_law, parks_law),
              list(~ replace_na(., "no_divided"))) %>% 
    mutate_at(vars(building_structure, use_district),
              .funs = list(~ replace_na(., "_missing"))) %>% 
    as.data.frame() %>% 
    # remove... attribute_change_building_coverage, attribute_change_parks_law
    janitor::remove_constant() %>% 
    as_tibble() %>% 
    verify(ncol(.) == 41) %>% 
    mutate(surrounding_present_usage = as.character(surrounding_present_usage),
           configuration = stringr::str_replace_all(configuration,
                                                    c(`四角形` = "square",
                                                      `台形` = "trapezoid",
                                                      `不整形` = "distorted")),
           current_use =  stringr::str_replace_all(current_use,
                                                   c(`その他` = "other",
                                                     `医院` = "hospital",
                                                     `銀行` = "bank",
                                                     `事務所` = "office",
                                                     `旅館` = "ryokan",
                                                     `給油所` = "gas_station",
                                                     `工場` = "factoty",
                                                     `倉庫` = "warehouse",
                                                     `農地` = "farmland",
                                                     `山林` = "woodland",
                                                     `空地` = "vacant_land",
                                                     `作業場` = "workspace",
                                                     `原野` = "wilds",
                                                     `用材` = "lumber",
                                                     `雑木` = "coppice",
                                                     `住宅` = "house",
                                                     `店舗` = "stoe"))),
  df_lp_kanto_clean2 = 
    df_lp_kanto_clean1 %>% 
    recipe(~ .) %>% 
    step_nzv(all_predictors()) %>% 
    step_corr(all_numeric(), threshold = 0.90) %>% 
    prep(training = df_lp_kanto_clean1) %>% 
    juice() %>% 
    verify(dim(.) == c(nrow(df_lp_kanto), 25)),
  remove_vars = 
    df_lp_kanto_clean2 %>%
    naniar::miss_var_summary() %>% 
    filter(n_miss > 0) %>% 
    verify(nrow(.) == 1) %>% 
    pull(variable),
  df_lp_kanto_clean = 
    df_lp_kanto_clean2 %>% 
    select(-remove_vars) %>% 
    verify(dim(.) == c(8476, 24)))
drake::make(plan_cleaning)
drake::loadd(list = c("df_lp_kanto_clean"))

# df_lp_kanto_clean %>% 
#   count(administrative_area_code)

# FE...
# building_structure... 会の情報を分離する
# surrounding_present_usage... 文字列のカウント

plan_lp_prep <- drake::drake_plan(
  df_lp_kanto_prep = 
    df_lp_kanto_clean %>%
    recipe(~ .) %>%
    step_dummy(configuration, fire_area, urban_planning_area, current_use, use_district, one_hot = TRUE) %>%
    prep(training = df_lp_kanto_clean, strings_as_factors = TRUE) %>%
    bake(new_data = df_lp_kanto_clean) %>% 
    verify(ncol(.) == 112L))
drake::make(plan_lp_prep)
drake::loadd(list = c("df_lp_kanto_prep"))

# spatial feature engineering ----------------------------------------------------------------
# source("https://gist.githubusercontent.com/uribo/5c67ef24dcaf17402175b0d474cd8cb2/raw/49d7a0072443bf7c397a548c946857b6cbc60c99/ksj_parse_s05.R")
source("https://gist.githubusercontent.com/uribo/5c67ef24dcaf17402175b0d474cd8cb2/raw/834f4acc07367e0e30772f6ef1eaed354fe287f8/ksj_parse_a16.R")
source("https://gist.githubusercontent.com/uribo/5c67ef24dcaf17402175b0d474cd8cb2/raw/54e69b230a8f6ce41bba0bd87a927243f63687da/ksj_parse_s12.R")

# 1. dist_to_tokyo... 東京駅からの距離
# 2. is_did... 人口集中地区 (DID) に含まれるかどうか
# # 座標系の違い
# # もっと離れていると...
# st_distance(
#   st_sfc(st_point(c(140.112, 36.083)), crs = 4326),
#   st_sfc(st_point(c(139.7671, 35.6812)), crs = 4326),
#   which = "Euclidean", 
#   by_element = TRUE) %>% units::set_units(km)
# st_distance(
#   st_transform(st_sfc(st_point(c(140.112, 36.083)), crs = 4326), crs = 6677),
#   st_transform(st_sfc(st_point(c(139.7671, 35.6812)), crs = 4326), crs = 6677),
#   which = "Euclidean", 
#   by_element = TRUE) %>% units::set_units(km)
plan_land_price_spatial_fe <- drake::drake_plan(
  sf_kanto_station = 
    ksj_parse_s12(here::here("data-raw/S12/S12-18_GML/S12-18_NumberOfPassengers.geojson")) %>% 
    st_join(st_union(ne_knt) %>% 
              st_sf(), join = st_within, left = FALSE) %>% 
    filter(S12_030 == 1, S12_031 == 1) %>% 
    select(station = S12_001, 
           # 2017年の駅別乗降客数（人/日）
           boarding = S12_033) %>% 
    verify(dim(.) == c(1990, 3)),
    #select(S12_001, num_range("S12_", range = 30:33, width = 3, prefix = "0")),
  sf_kanto_did =
    fs::dir_ls(here::here("data-raw/A16/"),
               regexp = paste0("A16-15_(",
                               paste0(sprintf("%02d", seq.int(8, 14)), collapse = "|"),
                               ")_GML/.+_DID.shp"),
               recurse = TRUE) %>%
    ensure(length(.) == 7L) %>% 
    purrr::map(ksj_parse_a16) %>%
    purrr::reduce(rbind) %>%
    lwgeom::st_make_valid() %>%
    st_union(),
  df_lp_kanto_sp_baked =
    df_lp_kanto_prep %>%
    select(.longitude, .latitude, everything()) %>% 
    mutate(station_data = purrr::pmap(
      .,
      ~ sf_kanto_station[sf::st_nearest_feature(st_sfc(st_point(c(..1, ..2)), crs = 4326), 
                                                sf_kanto_station), ] %>%
        st_drop_geometry()
    )) %>%
    tidyr::unnest(cols = "station_data") %>% 
    select(-name_of_nearest_station, -station) %>% 
    mutate(meshcode = jpmesh::coords_to_mesh(.longitude, .latitude)) %>% 
    st_as_sf(coords = c(".longitude", ".latitude"), crs = 4326) %>%
    mutate(dist_to_tokyo = st_distance(geometry,
                                       st_sfc(st_point(c(139.7671, 35.6812)), 
                                              crs = 4326))[,1],
           is_did = st_intersects(sf_kanto_did, geometry, sparse = FALSE)[1, ],
           .longitude = sf::st_coordinates(geometry)[, 1],
           .latitude = sf::st_coordinates(geometry)[, 2]) %>%
    st_drop_geometry() %>%
    assertr::verify(dim(.) == c(8476, 115)),
  if (dir.exists(here::here("data")) == FALSE) {
    dir.create(here::here("data"))
  },
  df_lp_kanto_sp_baked %>% 
    write_rds(here::here("data/lp_kanto.rds")))
drake::make(plan_land_price_spatial_fe)
drake::loadd(plan_land_price_spatial_fe, 
             list = c("df_lp_kanto_sp_baked"))
