---
interact_link: content/01/eda.ipynb
kernel_name: ir
has_widgets: false
title: '探索的データ分析'
prev_page:
  url: /01/tidy-data
  title: 'tidyデータと前処理'
next_page:
  url: /01/tidymodels-workflow
  title: 'モデルの構築から評価まで'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---



{:.input_area}
```
source(here::here("R/setup.R"))
```


# 探索的データ分析

データを料理する前に、どのようなデータが与えられているのか確認することが大切です。この段階を踏むことで、データに対する理解が深まり、より良いモデルの構築に繋がる可能性もあります。こうした一連の作業は探索的データ分析 (Exploratory Data Analysis: EDA)と呼ばれます。この作業には、データの集計、要約、可視化が含まれます。

EDAがデータ分析の作業において早期段階で行われるのは、データの異常（思い込みとの比較を含めて）や特徴を把握するためです。これらは分析全体のアプローチや良い出発点を見つけるために有効です。出発点と表現したのは、モデルの構築や特徴量の生成によって改めてデータを見つめ直す作業が発生するためです。そのため必ずしも徹底的である必要はありません。

前章でもデータについて簡単な調査を行いましたが、データをグラフによって表現してみましょう。グラフにすることで、集計値では見えなかった情報やデータ間の関係を表現できます。

特に欠損値や異常値（外れ値）、データの分布などデータ全体あるいはデータ間の関係性やそのばらつきを見るのに可視化は重要です。なお欠損値の視覚化については別の章で解説します。

## データを眺める

目的変数として設定する地価価格に影響を及ぼす変数を明らかにしたい、またその関係を知りたいという状況を設定します。

<!-- ここで扱うデータは地価公示データのみ。他のデータ、地価公示データの紹介は別のノート (`dataset/`)で。基本的に説明は地価公示データベース。データの性質に合わせて利用する。 -->

- サイズ（列数、行数）
- 各列のデータ型
- 完全データ、欠損データ

データを手に入れたら、分析作業へ取り掛かる前にまずはデータを眺めてみることにしましょう。眺める、と言ってもデータの値を1つずつ見ていくわけではありません。これから扱うデータにはどのような値が含まれているのか、データ型が処理されているか、また全体の大きさはどれくらいなのか欠損はどれだけあるかと言った情報を俯瞰的に整理していきます。

### データの大きさ

データフレームは行と列からなります。いくつかの関数を使って読み込んだデータの大きさを調べてみましょう。



{:.input_area}
```
dim(df_lp_kanto)
```


`dim()`をデータフレームに適用すると、そのサイズを数値ベクトルで返します。最初の要素が行数、2番目の数字が列数を示します。これは次の`ncol()`、`nrow()`により個別に求めることができます。




{:.input_area}
```
nrow(df_lp_kanto)
ncol(df_lp_kanto)
```


### データの一部を表示

データフレームの一部を表示して、列名と値の確認をしてみましょう。`head()`をデータフレームに対して実行すると先頭の数行を表示します。また`tail()` でデータフレームの最後の行を表示できます。いずれの関数も引数`n = ` に実数を与えることで表示される行数を制御可能です。



{:.input_area}
```
head(df_lp_kanto)

tail(df_lp_kanto, n = 3)
```


### 各列の情報

データ型や件数、欠損の状況を調べます。



{:.input_area}
```
glimpse(df_lp_kanto)
```


この地価公示データには45の列（変数）があります。

- データの型 (`character`, `numeric`, `logical`, `factor`)
- 欠損数、ユニーク数
- 文字データの長さの幅
- カテゴリデータの偏り、水準、順序
- 数値データの要約統計量、分布（ヒストグラム）

- `configuration`や`fire_area`は欠損を多く含んでいることがわかります。`building_structure`にもわずかですが欠損データがあります




{:.input_area}
```
# 同一のデータで重複があるもの
df_lp_kanto %>% 
  tidyr::separate_rows("current_use", sep = ",") %>% 
  count(.row_id) %>% 
  filter(n > 1) %>% 
  distinct(.row_id) %>% 
  nrow() %>% 
  ensure(. == 1986L)
```


明確な答えがあるわけではありませんが、以下の情報はデータ全体、各変数について把握しておくと良いでしょう。またデータの偏りや出現傾向、分布のパターンは可視化を行い確認するのが効率的です。

## 要約統計量の算出



{:.input_area}
```
summary(df_lp_kanto)
```


Rの組み込み関数として用意されている `summary()` を利用して、データフレームに含まれる列の要約統計量を得ることができます。



{:.input_area}
```
# 論理値型で標準偏差0の列を特定 constant cols
df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is.logical) %>% 
  mutate_all(as.numeric) %>% 
  summarise_all(sd) %>% 
  tidyr::gather()
```


ここでは `skimr::` で行う例を示します。



{:.input_area}
```
# skimr::skim(df_lp) # Rコンソールでの実行は skim() で構いません
df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  skimr::skim_to_list()
```


論理型データのうち、`attribute_change_forest_law` と `attribute_change_parks_law` は FALSE のみが出現していることがわかります。

## 探索的データ分析

モデリングでは、目的変数の挙動（予測、分類）を明らかにすることがゴールとして設定されます。変数が多いデータであるほど確認する図の数が多くなり、効率的ではなくなります。そのため、まずはモデリングの目的変数となるデータを詳しく見ることを勧めます。また、この段階で作る図は初期モデルを構築する前段階で示唆を提供するものであると望ましいです。そこで目的変数に影響する説明変数、説明変数間の関係を明らかにすることで、次のモデリングプロセスに活かせる知識を得られることが期待できます。

探索的データ分析の結果が最終的な成果物になることは稀です。ここで作られる図は論文や書籍、プレゼンテーションのための図ではありません。つまり複雑な図を作ることは求められていません。ここでは主にggplot2による作図を行いますが、扱いに慣れた最低限の機能を提供しれくれるライブラリを利用すると良いでしょう。

以下では引き続き、地価公示データを使います。このデータには位置情報も含まれているため、地図上へのデータのマッピングも試みます。

また時系列データの例としてビールへの支出データも利用します。

## 数値データ



{:.input_area}
```
df_is_num <- 
  df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is_numeric)
```


## カテゴリデータ



{:.input_area}
```
df_is_cat <- 
  df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is.character) %>% 
  verify(ncol(.) == 13)
```




{:.input_area}
```
df_is_cat %>% 
  count(name_of_nearest_station, sort = TRUE)
```


## 論理値



{:.input_area}
```
df_is_log <-
  df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is.logical) %>% 
  verify(ncol(.) == 17)
```




{:.input_area}
```
gg_count_var <- function(data, var) {
  var <- rlang::enquo(var)
  var_label <- rlang::quo_name(var)
    data %>% 
    count(!!var) %>% 
    ggplot(aes(forcats::fct_reorder(!!var, n), n)) +
    geom_bar(stat = "identity") +
    labs(x = var_label) +
    coord_flip()
}
```




{:.input_area}
```
df_is_cat %>% 
  filter(stringr::str_detect(administrative_area_code, "^08")) %>% 
  gg_count_var(name_of_nearest_station)
```


![](../images/pref08_name_of_nearest_station-1.png)



{:.input_area}
```
purrr::map(
  rlang::syms(str_subset(names(df_is_cat), "name_of_nearest_station", negate = TRUE)),
  ~ gg_count_var(df_is_cat %>% 
                   filter(stringr::str_detect(administrative_area_code, "^08")), 
                 !!.x)) %>% 
    plot_grid(plotlist = ., ncol = 2)
```


![](../images/pref08_categorical_count-1.png)

何枚かの図は文字が潰れてしまいましたが、いくつかのカテゴリデータについて掴めたことがあります。


### 全体



{:.input_area}
```
vis_dat(df_lp_kanto)
```


### 1変数の可視化

データのばらつきを見るのにはヒストグラム、箱ひげ図を利用します。一変量を対象とした単純な可視化は、変数の変動、特性を理解するのに役立ちます。

#### ヒストグラム

スパイク（峰）を検出するのに効果的です。ヒストグラムは単峰、二峰など多様な形状を取り得ます。



{:.input_area}
```
df_lp_kanto %>% 
  ggplot(aes(posted_land_price)) +
  geom_histogram(bins = 30)
```


<!-- box-cox変換をする図をあとで -->



{:.input_area}
```
df_lp_kanto %>% 
  ggplot(aes(posted_land_price)) +
  geom_density() +
  facet_wrap(~ .prefecture, ncol = 1)
```




{:.input_area}
```
library(ggridges)

ggplot(df_lp_kanto, 
       aes(x = posted_land_price, y  = .prefecture)) +
  scale_x_log10() +
  ggridges::geom_density_ridges(scale = 4)
```


#### 箱ひげ図・バイオリンプロット

### 2変数の可視化




{:.input_area}
```
df_lp_kanto %>% 
  ggplot(aes(use_district, posted_land_price)) +
  geom_boxplot()
```


#### 散布図



{:.input_area}
```
df_lp_kanto %>% 
  ggplot(aes(distance_from_station, posted_land_price)) +
  geom_point()
```




{:.input_area}
```
df_lp_kanto %>% 
  ggplot(aes(distance_from_station, acreage)) +
  geom_point()
```


## 特殊なデータの視覚化

### 時系列データ

時系列データを扱うときは、時間のならびの通りに表示させることが肝心です。周期があるものは分割したり重ねてみると良いでしょう。



{:.input_area}
```
df_beer2018q2 %>% 
  ggplot(aes(date, expense)) +
  geom_point() +
  geom_line() +
  scale_x_date(date_breaks = "7 days")
```




{:.input_area}
```
df_beer2018q2 %>% 
  ggplot(aes(expense)) +
  geom_histogram(bins = 30)
```


### 空間データ



{:.input_area}
```
sf_lp_kanto <- 
  df_lp_kanto %>% 
  select(posted_land_price, .longitude, .latitude) %>% 
  st_as_sf(coords = c(".longitude", ".latitude"), crs = 4326)

ggplot(sf_lp_kanto) +
  geom_sf(aes(color = posted_land_price),
          fill = "transparent", alpha = 0.1, size = 0.5) +
  scale_color_viridis_c()
```


<!-- ksjのクレジット -->

<!-- アンスコムの例 -->

### 高次元の可視化

3次元の世界に生きる我々は、高次元のデータを直接扱うことに慣れていません。

次元圧縮を行ってからの可視化が効果的です。

#### ヒートマップ

変数間の関係、特に相関や欠損関係がある場合に役立ちます。

#### 散布図行列




{:.input_area}
```
df_is_num %>% 
  GGally::ggpairs()

df_is_num %>% 
  corrr::correlate()
```




{:.input_area}
```
df_is_num %>% 
  vis_cor()

df_is_log %>% 
  mutate_all(as.numeric) %>% 
  vis_cor()

all.equal(
  df_lp_kanto$attribute_change_building_coverage,
  df_lp_kanto$attribute_change_floor_area_ratio)
```


#### t-SNE

高次元データの2次元散布図を用いた可視化に利用される

#### モデルの利用

効果的な変数の仮説がない場合や、変数の量が多い場合には、EDAの前に木ベースのモデルを適用してみるのも戦略の1つです。これらのモデルでは目的変数に対する説明変数の貢献度として、変数重要度を示すことが可能です。これによりEDAのとっかかりを得ることが可能になるはずです。変数重要度については後の章で解説します。

## まとめ

- モデリング、統計分析を行う前にデータを精査することが大事
    - データの特徴を理解することで次のステップにかける時間を減らす、異常を見逃さない、（意図しない）間違いを見逃さない
- 特に可視化の手法を用いることでデータの集約や関係、パターンを見やすくする

## 関連項目

- 次元削減
- 欠損処理
- 変数重要度

## 参考文献
