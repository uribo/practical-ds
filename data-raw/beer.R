################################
# ビールへの支出データ
# Source: 家計調査 家計収支編 二人以上の世帯 詳細結果表
#   日別支出 品目分類による日別支出
# Subset: 2018年7~9月, 2015~2018年月平均
###############################
library(dplyr)
library(assertr)
library(jmastats)
library(lubridate)
library(drake)

parse_beer_expense <- function(path, year, month) {
  d <-
    readxl::read_xls(path, sheet = 1, skip = 8, col_types = "text")
  
  d <-
    d %>%
    purrr::set_names(d %>% names() %>% stringr::str_remove_all(" ")) %>%
    janitor::clean_names() %>%
    # slice(-seq.int(3)) %>%
    dplyr::filter(`品目分類` == "ビール") %>%
    assertr::verify(nrow(.) == 1L) %>% 
    dplyr::select(tidyselect::ends_with("日")) %>%
    tidyr::gather(date, expense) %>%
    dplyr::mutate(date = stringr::str_replace(date, "x", glue::glue("{year}年{month}月")) %>%
                    lubridate::as_date(),
                  expense = as.numeric(expense))
  d
}
plan_beer_raw <- drake_plan(
  files = fs::dir_ls(here::here("data-raw"), regexp = "_a616.xls$"),
  # 統計表のダウンロード --------------------------------------------------------------
  estats_download = {
    if (rlang::is_false(length(files) == 48L)) {
      
      library(rvest)
      # https://www.e-stat.go.jp/stat-search/files?page=1&layout=datalist&cycle=1&toukei=00200561&tstat=000000330001&tclass1=000000330001&tclass2=000000330004&tclass3=000000330005&cycle_facet=tclass1%3Acycle&second2=1&year=20180&month=24101211&result_back=1
      base_url <- "https://www.e-stat.go.jp"
      year_index <- 
        seq(2, 5) %>% 
        purrr::set_names(seq(2018, 2015))
      x <-
        glue::glue(base_url, "/stat-search/files?page=1&layout=datalist&toukei=00200561&tstat=000000330001&cycle=1&tclass1=000000330001&tclass2=000000330004&tclass3=000000330005&cycle_facet=tclass1%3Acycle&second2=1") %>% 
        read_html()
      
      # year_index を変更して繰り返す
      x %>% 
        html_nodes(css = glue::glue('body > div.dialog-off-canvas-main-canvas > div > main > div.row.l-estatRow > section > div.region.region-content > div > div > div.stat-content.fix > section > section > div > div.stat-cycle_sheet > ul:nth-child({year_index}) > li.stat-cycle_item > div > a',
                                    year_index = year_index[2])) %>% 
        html_attr("href") %>% 
        stringr::str_c(base_url, .) %>%
        purrr::walk2(
          .y = seq.int(12),
          .f = ~ read_html(.x) %>% 
            html_nodes(css = 'body > div.dialog-off-canvas-main-canvas > div > main > div.row.l-estatRow > section > div.region.region-content > div > div > div.stat-content.fix > section > section > div > div.stat-dataset_list > div > article > div > ul > li > div > div > a') %>% 
            html_attr("href") %>% 
            .[length(.)] %>% 
            stringr::str_c(base_url, .) %>% 
            httr::GET(
              httr::write_disk(glue::glue("data-raw/{year_index}{stringr::str_pad(month_index, , width = 2, pad = '0')}_a616.xls",
                                          year_index = names(year_index[2]),
                                          month_index = .y), 
                               overwrite = TRUE)))
    }
  },
  # parse -------------------------------------------------------------------
  df_beer =
    fs::dir_ls(here::here("data-raw"), regexp = "_a616.xls$") %>% 
    purrr::map_dfr(
      ~ parse_beer_expense(.x, 
                           year = stringr::str_sub(basename(.x), 1, 4), 
                           month = as.numeric(stringr::str_sub(basename(.x), 5, 6)))) %>% 
    assertr::verify(data = ., expr = dim(.) == c(1461, 2)),
  df_beer_month_avg = 
    df_beer %>% 
    mutate(year = year(date),
           month = month(date)) %>% 
    group_by(year, month) %>% 
    summarise(expense = mean(expense)) %>% 
    ungroup() %>% 
    verify(dim(.) == c(48, 3)),
  df_weather_monthly_avg = 
    df_beer_month_avg %>% 
    distinct(year) %>% 
    purrr::pmap_dfr(
      ~ jmastats::jma_collect("monthly", "47662", year = ..1, month = 1) %>% 
        select(month, contains("average"), 
               contains("humidity_mean"), 
               contains("snow_fall"),
               "cloud_covering_mean",
               ends_with("days")) %>% 
        jmastats:::parse_unit(data = ., rename = TRUE) %>% 
        mutate(year = ..1) %>% 
        select(year, everything())) %>% 
    verify(dim(.) == c(48, 13)),
  df_beer_monthly_avg =
    df_beer_month_avg %>% 
    left_join(df_weather_monthly_avg, by = c("year", "month")) %>% 
    verify(dim(.) == c(48, 14)),
  df_beer_monthly_avg %>% 
    readr::write_csv(here::here("data-raw/beer.csv"))
)
drake::make(plan_beer_raw)
drake::loadd(list = c("df_beer"))

plan_beer_subset <- drake_plan(
  df_weather2018q2 = seq.int(7, 9) %>% 
    purrr::map_dfr(
      ~ jma_collect("daily", "47662", year = 2018, month = .x) %>% 
        select(date, 
               `weatherdaytime (06:00-18:00)`,
               `precipitation_sum(mm)`,
               starts_with("humidity_average"),
               starts_with("temperature"))) %>% 
    jmastats:::parse_unit(data = ., rename = TRUE) %>% 
    verify(dim(.) == c(92, 7)),
  df_beer2018q2 = 
    df_beer %>% 
    filter(
      lubridate::year(date) == 2018,
      # 4月始まりの四半期
      lubridate::quarter(date, fiscal_start = 4) == 2L) %>% 
    verify(nrow(.) == 92L) %>% 
    left_join(df_weather2018q2, by = "date"),
  df_beer2018q2 %>% 
    readr::write_csv(here::here("data-raw/beer2018q2.csv"))
)
drake::make(plan_beer_subset)
drake::loadd(list = c("df_beer2018q2"))
rm(parse_beer_expense)
