---
interact_link: content/02/date-and-time.ipynb
kernel_name: ir
title: '日付・時間データの取り扱い'
prev_page:
  url: /02/text
  title: 'テキストデータの取り扱い'
next_page:
  url: /02/spatial-data
  title: '地理空間データの取り扱い'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---



{:.input_area}
```R
source(here::here("R/setup.R"))
library(lubridate)
```


# 日付・時間データの取り扱い

ビールへの支出データ、土砂災害・雪崩メッシュデータを利用します。

- 経過時間
- タイムゾーン

期間内のある瞬間の情報

特定のイベントからの経過時間

ビールの売り上げに対して、何が効いているか、効いていないか予測を立ててみましょう

* 平日・休日
    * より厳密には週末かそうでないか… そんなに効かない。土日は効果あり
    * 連休の数
        * 平日金曜日は0.5?
* 夏休み？？
* 関係しそうではないもの
    * 月初、月末
    
## 要素の分解

日付や時間のデータは複数の要素で構成されます。例えば「2019年7月10日」であれば、年月日をそれぞれ分けて2019、7、10に分解可能です。これに時間が加わればさらに時分秒の要素に分解することもできます。

ビールの売り上げを考えたとき、大事な日付の要素は何でしょうか。

ということがない限り、年の影響は小さそうです。小さなデータセットでは一年分しかない場合もあります（分散0）。

日付もそれほど重要ではなさそうです。むしろ日付によって変わる平日・休日の違いが影響しそうですが、これについてはあとで処理を加えていくことにします。




{:.input_area}
```R
rep_split_date <- 
  df_beer2018q2 %>% 
  recipe(expense ~ .) %>% 
  step_date(date)

df_beer_prep <- 
  rep_split_date %>% 
  prep(training = df_beer2018q2) %>% 
  juice(expense, starts_with("date"), temperature_average)

df_beer_prep
```


## カレンダー（祝日）

人の行動による影響を受けるデータでは、日付の平日・休日を区別することが重要になることが多いです。それは平日と休日では人々の行動様式が異なると考えられるためです。

一方でハザードデータのように自然活動を扱うデータではこの要素が影響するとは考えられません。

データが記録された日付が平日か休日

7月から9月にかけては

海の日（7月第3月曜日）
山の日 (8月11日) ... 2016年に設立。
敬老の日 (9月第3月曜日)
秋分の日 (秋分日... )

が祝日です。

また、この期間で考慮すべき日付として「お盆」の期間があります。多くの企業でこの期間は夏休みとなっていると考えられます。8月13日から15日のデータも他の日付と区別できるようにしておきます。



{:.input_area}
```R
df_beer_prep <- 
  df_beer_prep %>% 
  recipe(expense ~ .) %>% 
  step_holiday(date,
               holidays = timeDate::listHolidays("JP") %>% 
                 str_subset("UmiNoHi|KeirouNOhi|ShuubunNoHi")) %>% 
  prep() %>% 
  bake(new_data = df_beer_prep) %>%
  # timeDate::listHolidays() が山の日に未対応なのでフラグを作る処理を用意する
  mutate(date_JPYamaNoHi = as.numeric(date == ymd("2018-08-11")),
         is_obon = between(date, ymd("2018-08-13"), ymd("2018-08-15")))

df_beer_prep
```


平日であれば1を与える列を追加します。



{:.input_area}
```R
df_beer_prep <- 
  df_beer_prep %>% 
  mutate(is_weekday = if_else(date_dow %in% c("土", "日"),
                              0,
                              if_else(date_JPKeirouNOhi == 1 | date_JPShuubunNoHi == 1 | date_JPUmiNoHi == 1 | date_JPYamaNoHi == 1,
                                      0,
                                      if_else(is_obon == 1,
                                              0,
                                              1))
                              )) %>% 
  select(expense, is_weekday, date_month, temperature_average)

df_beer_prep
```




{:.input_area}
```R
df_beer_baked <- 
  df_beer_prep %>% 
  recipe(expense ~ .) %>% 
  step_log(expense, temperature_average, base = 10) %>% 
  prep() %>% 
  juice()
```


## 自己相関
## 季節成分・周期成分

weeks

df_beerの方で??
df_hazard

<!--## タイムゾーン -->
