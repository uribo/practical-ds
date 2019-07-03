---
interact_link: content/02/categorical.ipynb
kernel_name: ir
title: 'カテゴリデータの取り扱い'
prev_page:
  url: /02/numeric
  title: '数値データの取り扱い'
next_page:
  url: /02/text
  title: 'テキストデータの取り扱い'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---



{:.input_area}
```R
source(here::here("R/setup.R"))
library(cattonum)

df_hazard <- 
  df_hazard %>% 
  st_drop_geometry()
```


# カテゴリデータの取り扱い

ダミー変数の作成

多くの統計・機械学習モデルでは、数値化を求めます。

だめ... SVM、ニューラルネットワーク

xgboost, glmnet etc.

カテゴリの変数には、次にあげる特徴が含まれる場合があります。

1. 大小または順序関係
2. 重み

ここで紹介する多くの特徴量エンジニアリングは、カテゴリ変数がもつ特徴を考慮しつつ、数値化するものとなります。

定性的

一方で、数値のように扱える郵便番号などは数値として扱ってはいけません。これらは数値出会っても大小関係や連続的な意味をもたないためです。

「どれだけ違うか」ではなく「値が異なることが重要」

メッシュコード

尺度の問題？？

カテゴリに順序を与える
大きさを示す変数として「大」、「中」、「小」の3項目がある場合、「大」は「小」よりも大きいことはわかります。この関係は1から3の数値に示すことが可能で、大は一番大きな値である3と対応するという変換を行うことができます。

ここではビールへの支出データおよび土砂災害・雪崩メッシュデータを利用します。



{:.input_area}
```R
df_beer2018q2
df_hazard
```


カテゴリ変数の特徴量エンジニアリングには、次元を増やす、増やさないの両方のパターンがあります。

それぞれの方法をみていきましょう。

色々ある。これで全てではない。weight of evidenceなど。

カテゴリを数値に変換する処理のことを全般的にエンコーディング

## ビンカウンティング

統計量を当てはめるのをビンカウンティング

### カウントエンコーディング

カウント変数の項目に対して、頻度を求めたものがカウントエンコーディングです。



{:.input_area}
```R
set.seed(1236)
df <- 
  df_hazard %>% 
  sample_n(10) %>% 
  select(hazardDate, hazardType, maxRainfall_h)
df
```


このようなデータに対して、hazardTypeのカウントエンコーディングを適用すると次のようになります。



{:.input_area}
```R
df %>% 
  group_by(hazardType) %>% 
  mutate(hazardDate,
            hazardType_ = n(),
            maxRainfall_h) %>% 
  ungroup() %>% 
  select(hazardDate, hazardType = hazardType_, maxRainfall_h)
```


カテゴリ内での出現頻度が多ければ多いほど、特徴量の値は大きくなり、影響も強くなります。一方で、元は異なる水準であったものが同じ出現頻度であった場合にはエンコード後の値が同じになってしまうことに注意です。例では、出現頻度が1の「地すべり」と「雪崩」

### ラベルエンコーディング

ラベルエンコーディング (label encoding) はカテゴリに対して一意の数値を割り振るというアイデアが単純なものですが、それではカテゴリがもつ特徴を拾い上げることはできません。



{:.input_area}
```R
df_hazard %>% 
  st_drop_geometry() %>% 
  group_by(hazardType) %>% 
  slice(1:2L) %>% 
  ungroup() %>% 
  distinct(hazardType, hazardType_sub, .keep_all = TRUE) %>% 
  select(hazardType) %>% 
  mutate(hazardType_num = as.numeric(as.factor(hazardType))) %>% 
  head(10)
```


### ターゲットエンコーディング

ターゲットエンコーディング (target-based encoding, likelihood encoding) は、カテゴリ変数と対応する目的変数の値を利用した方法です。カテゴリ変数の水準ごとに、水準の項目を目的変数の平均値に置き換えるという処理を行います。例えば、カテゴリ変数にAという項目が4つ含まれ、それぞれに1.5, 3.0, 0, 1.2のoutcomeが与えられているとします。この場合、outcomeの平均値は1.425なので、カテゴリ変数のAは1.425に置き換えられます。また以下のように目的変数が論理値である場合には、それを数値に変換した値を利用します（RではTRUEが1、FALSEが0）。



{:.input_area}
```R
df <- 
  tibble(
  feature = c("A", "A", "A", "A", "B", "B", "C", "C"),
  outcome = c(TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE, TRUE)) %>% 
  add_count(feature)

df

df %>% 
  mutate(outcome = as.numeric(outcome)) %>% 
  catto_mean(response = outcome)

# df_target_enc <- 
#   df %>% 
#   add_count(feature) %>%
#   group_by(feature) %>% 
#   mutate(mean_encode = sum(outcome) / n) %>% 
#   ungroup() %>% 
#   select(-feature)
# 
# df_target_enc
```


データリークを起こしてしまう問題がある。

また

頻度の低い水準がある場合も過学習の原因になってしまう可能性がある。

#### Leave one out エンコーディング

ターゲットエンコーディングの計算において、

データリークを防ぐように

自身を除いて計算します。

完全に防げるわけではない?



{:.input_area}
```R
# df_target_enc %>% 
#   group_by(feature) %>% 
#   mutate(loo_encode = lead(outcome))

df %>% 
  mutate(outcome = as.numeric(outcome)) %>% 
  catto_loo(response = outcome)
```


### CatBoost

## ダミー変数化

カテゴリ変数を数値に変換する処理は
エンコードと呼ばれます。

### ダミーコーディング



{:.input_area}
```R
mod_fml <- formula(expense ~ date + weatherdaytime_06_00_18_00)
```


どうして一つ減るのか

- 他のダミー変数の値から残り一つの値が推測できる... 他が0であれば1、他のダミー変数に1があれば0

フルランク未満のエンコーディングは One-hotエンコーディング

- ダミー変数が多くなると次元の数が増える (データ件数を上回ることも)

曜日をダミーコーディングする例を考えてみましょう。曜日は7つの値を取りますが、

コントラスト関数は6つのダミー変数で曜日を表現することになります。

6列... 該当する曜日で1, そうでない場合に0

まずは年月日からなる日付の変数から曜日を取り出す必要があります。



{:.input_area}
```R
df_baked_split_date <- 
  df_beer2018q2 %>% 
  recipe(mod_fml) %>% 
  step_date(date) %>% 
  prep(training = df_beer2018q2) %>% 
  bake(new_data = df_beer2018q2)

glimpse(df_baked_split_date)
```


日付を記録するdate列の要素が分解され、新たな特徴量として追加されました。それでは曜日のダミーコーディングを実行します。



{:.input_area}
```R
df_baked_split_date %>% 
  recipe(expense ~ .) %>% 
  step_dummy(date_dow) %>% 
  prep(training = df_baked_split_date) %>% 
  bake(new_data = df_baked_split_date) %>% 
  select(starts_with("date_dow"), everything())
```


今度は分解した曜日の情報をもとに、ビールの売り上げは「翌日に仕事が控えている曜日よりも休日の方が増えそうだ」という直感を調べてみましょう。



{:.input_area}
```R
df_baked_split_date <- 
  df_baked_split_date %>% 
  mutate(is_weekend = if_else(date_dow %in% c("土", "日"),
                              TRUE,
                              FALSE))
```




{:.input_area}
```R
df_baked_split_date %>% 
  ggplot(aes(date_dow, expense)) +
  geom_boxplot(aes(color = is_weekend), outlier.shape = NA) +
  geom_jitter(aes(color = is_weekend), alpha = 0.3) +
  scale_color_ds() +
  facet_wrap(~ date_month)
```


目論見通り、どの月でも平日よりも休日の方が支出が増えているようです。また、8月は週ごとに変動が大きく、9月では平日との差がほとんどないということもグラフから読み取れます。新たな特徴量の作成と関係の図示により、経験的な推論を確認するだけでなく、モデルに対する新たな洞察も得ることができました。



{:.input_area}
```R
# 日本の祝日判定に次の項目が利用可能
stringr::str_subset(timeDate::listHolidays(), "^JP")
```


カテゴリに含まれる項目のうち

k-1の

### One-hotエンコーディング

カテゴリ変数に含まれる項目を新たな列として扱い、カテゴリに該当する場合は1、そうでない場合には0を与えていく方法です。

ダミー変数とは異なり、ターゲットの項目も残るのが特徴です。

> one-hot表現というのはある要素のみが1でその他の要素が0であるような表現方法



{:.input_area}
```R
df_baked_split_date %>% 
  recipe(expense ~ .) %>% 
  step_dummy(date_dow, one_hot = TRUE) %>% 
  prep(training = df_baked_split_date) %>% 
  bake(new_data = df_baked_split_date) %>% 
  select(starts_with("date_dow"), everything())
```


> カテゴリ数に応じて列数が増えることや、新しい値が出現する度に列数を増やす必要があることが問題点

ダミーコーディングでは、カテゴリが多い場合にデータサイズが増大し、さらに大量の0と一部の1を含んだスパースデータ (sparse data) になりやすいことに留意しましょう。カテゴリの数が多い場合には次の特徴量ハッシュやビンカウンティングが有効です。

<!-- スパースデータは計算コストが大きくなります -->

### effectコーディング

## カテゴリ変数の縮約・拡張

### Polynomial encoding

### Expansion encoding

ビールの支出データに含まれるweatherdaytime_06_00_18_00には、「晴」や「曇」だけでなく「曇一時雨」や「雨後時々曇」といった気象に関する項目が含まれます。項目の組み合わせによる表現が可能であるため、カテゴリの数は多くなっています。



{:.input_area}
```R
df_beer2018q2 %>% 
  count(weatherdaytime_06_00_18_00)
```


この一次や時々によって区切ることが可能な項目

を新たな特徴量として活用するのがexpansion encodingになります。



{:.input_area}
```R
df_beer2018q2_baked <- 
  df_beer2018q2 %>% 
  select(date, expense, weatherdaytime_06_00_18_00) %>% 
  tidyr::separate(weatherdaytime_06_00_18_00, 
                  sep = "(後一時|一時|後時々|時々|後)", 
                  into = paste("weatherdaytime_06_00_18_00", 
                                c("main", "sub"),
                               sep = "_"))

df_beer2018q2_baked
```


複雑なカテゴリを評価するのではなく、大雑把なカテゴリとして扱いたい場合にはカテゴリの項目を減らすことが有効でしょう。



{:.input_area}
```R
df_beer2018q2_baked %>% 
  count(weatherdaytime_06_00_18_00_main,
        weatherdaytime_06_00_18_00_sub)
```


## 多くのカテゴリを持つ場合の処理

ビンカウンティング以外の方法を紹介します。

<!-- 次元削減の項目も参照 -->

### ターゲットエンコーディングの平滑化処理

### 特徴量ハッシング

ハッシュ関数を利用した

固定の配列に変換する

## まとめ

- カテゴリ変数はツリーベースのモデルを除いて、モデルに適用可能な状態、数値に変換する必要がある
- もっとも単純なものはカテゴリに含まれる値を独立した変数として扱うこと
    - カテゴリ内の順序を考慮するには別な方法が必要
- テキストも同様に数値化が必要。一般的には頻度の少ない単語が除外される。

## 関連項目

## 参考文献

- Max Kuhn and Kjell Johnson (2013). Applied Predictive Modeling (Springer)
