# 欠損の補完 imputation --------------------------------------------------------------
# df_hazard_kys_lands <- 
#   readr::read_csv("data-raw/hazard_kyusyu201607.csv")
# knn... 欠損のないデータで訓練
# library(tidymodels)
library(mice)
# library(ggplot2)
drake::loadd(list = c("df_hazard_kys_lands", "land_vars"))
plan_landset_imputation <- drake::drake_plan(
  df_landset =
    df_hazard_kys_lands %>%
    sf::st_drop_geometry() %>% 
    dplyr::select(meshCode, land_vars) %>% 
    dplyr::distinct(meshCode, .keep_all = TRUE) %>%
    dplyr::mutate(meshCode = as.character(meshCode)) %>% 
    janitor::remove_empty("cols") %>% 
    assertr::verify(dim(.) == c(630, 10)),
  landset_imp = mice(df_landset, m = 10, maxit = 5, meth = "pmm", seed = 500),
  landset_completed = mice::complete(landset_imp, 1),
  df_landset_comp =
    landset_completed %>% 
    select(-c(landset_completed %>% 
                naniar::miss_var_summary() %>% 
                filter(pct_miss > 0) %>% 
                pull(variable))) %>% 
    as_tibble())
drake::make(plan_landset_imputation, packages = c("dplyr", "mice", "assertr", "sf"))
drake::loadd(list = plan_landset_imputation$target)


# dimension reduction -----------------------------------------------------
library(recipes)
# PCA
# 地形の変数を圧縮
plan_dimension_reduction <- drake::drake_plan(
  land_vars_update = land_vars[land_vars %in% names(df_landset_comp)] %>% 
    ensure(length(.) == 8L),
  pca_rec =
    df_landset_comp %>% 
    recipe(~ .) %>% 
    step_center(land_vars_update) %>%
    step_scale(land_vars_update) %>%
    # 3要素を考慮できるように
    step_pca(land_vars_update, num_comp = 3),
  pca_estimates = prep(pca_rec, training = df_landset_comp),
  pca_data = bake(pca_estimates, df_landset_comp)
)
drake::make(plan_dimension_reduction,
            packages = c("recipes", "ensurer"))
drake::loadd(list = c("pca_data", "land_vars_update"))
