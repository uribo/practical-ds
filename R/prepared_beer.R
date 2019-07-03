source(here::here("R/setup.R"))

plan_beer_prep <- drake::drake_plan(
  pca_res = 
    df_beer %>% 
    select(-month, -ends_with("days"), -cloud_covering_mean) %>% 
    select(-year) %>% 
    select(-expense) %>% 
    prcomp(., center = TRUE, .scale =  TRUE) %>% 
    summary(),
  split_beer = 
    df_beer %>% 
    initial_time_split(),
  df_beer_train = 
    split_beer %>% 
    training(),
  df_beer_test = 
    split_beer %>% 
    testing(),
  beer_dimension_reduce_rec = 
    df_beer_train %>% 
    recipe(expense ~ .) %>% 
    step_rm(year) %>% 
    step_center(all_predictors(), -month, -ends_with("days"), -cloud_covering_mean) %>% 
    step_scale(all_predictors(), -month, -ends_with("days"), -cloud_covering_mean) %>% 
    step_pca(all_predictors(), -month, -ends_with("days"), -cloud_covering_mean,
             num_comp = 2)
)
drake::make(plan_beer_prep)
drake::loadd(plan_beer_prep, list = c("df_beer_train", "df_beer_test", "beer_dimension_reduce_rec"))


df_beer_train <- 
  beer_dimension_reduce_rec %>% 
  prep() %>% 
  juice()

df_beer_test = 
  beer_dimension_reduce_rec %>% 
  prep() %>% 
  bake(new_data = df_beer_test)
