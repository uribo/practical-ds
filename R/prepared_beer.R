################################
# 単純な分割
################################
source(here::here("R/setup.R"))

plan_beer_prep <- drake::drake_plan(
  # 第3主成分で96%を説明
  pca_res = 
    df_beer %>% 
    select(-month, -ends_with("days"), -cloud_covering_mean) %>% 
    select(-year) %>% 
    select(-expense) %>%
    # 気温、湿度、風速などの気象変数でPCA
    stats::prcomp(., center = TRUE, scale. =  TRUE) %>% 
    summary(),
  # data split
  split_beer = 
    df_beer %>% 
    initial_time_split(prop = 3/4),
  df_beer_train = 
    split_beer %>% 
    training(),
  df_beer_test = 
    split_beer %>% 
    testing(),
  beer_dimension_reduce_rec = 
    df_beer_train %>% 
    recipe(expense ~ .) %>% 
    # 年の情報は使わない
    step_rm(year) %>% 
    # 主成分分析、第3主成分までの主成分得点を特徴量として利用
    step_center(all_predictors(), -month, -ends_with("days"), -cloud_covering_mean) %>% 
    step_scale(all_predictors(), -month, -ends_with("days"), -cloud_covering_mean) %>% 
    step_pca(all_predictors(), -month, -ends_with("days"), -cloud_covering_mean,
             num_comp = 3),
  df_beer_baked_train =
    beer_dimension_reduce_rec %>% 
    prep(training = df_beer_train) %>% 
    bake(new_data = df_beer_train),
  df_beer_baked_test = 
    beer_dimension_reduce_rec %>% 
    prep(training = df_beer_train) %>% 
    bake(new_data = df_beer_test)  
)
drake::make(plan_beer_prep, seed = 123,
            packages = c("dplyr", "recipes", "rsample"))
drake::loadd(list = c("df_beer_train",
                      "df_beer_test",
                      "df_beer_baked_train", 
                      "df_beer_baked_test", 
                      "beer_dimension_reduce_rec"))
