---
interact_link: content/03/feature-selection.ipynb
kernel_name: ir
has_widgets: false
title: '変数重要度'
prev_page:
  url: /03/data-splitting
  title: 'データ分割'
next_page:
  url: /03/parameter-tuning
  title: 'ハイパーパラメータの調整'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---



{:.input_area}
```R
source(here::here("R/prepared_landprice.R"))
```


# 特徴量選択

特徴量を増やす（モデルを複雑にする）ことの問題

## 高次元データの問題

- 学習に時間がかかる
- 多重共線性
- ノイズや過学習の原因
- 次元の呪い

変数間の相関に由来する問題は多重共線性と呼ばれます

多重共線性への対策として、事前に共線性をもつ変数を削除しておくというものがあります。

これを変数選択と言います。

一方でモデルに重要な変数を削除してしまう恐れもあります。

> > 余分な変数をモデルに取り組むよりもリスクよりも重要な変数をモデルに取り込まないリスクの方が大きい

変数選択 (feature selection)は慎重に、かつ比較を十分に行うべきでしょう。

次元削減 (feature reduction)

真に必要な変数を探すための作業と言えるかもしれません。

### 多重共線性

VIFでは数値による客観的指標を用いてモデルに組み込む変数を選択することができる

大きく異なるが、多重共線性を生じるVIFの値としては4~10が使われることが多いです。

相関の強い変数をモデルに取り入れることで発生する問題です。

回帰係数が不安定
推定結果の分散が大きくなる

対策としては、事前に共線性をもつ変数を除外する、変数の情報の一部を利用するなどです。情報の一部とは、主成分分析でばらつきを最も反映する成分となります。これにより変数間の関係を無相関化が行われます。

散布図行列を描いて、モデルに用いる変数間の相関を見る。

相関係数を確かめる。

多重共線性

完全相関の変数が含まれると推定値が計算されません。



{:.input_area}
```R
tibble(
  y = seq_len(100),
  x1 = rnorm(100),
  x2 = x1
) %>% 
  lm(y ~ ., data = .)
```




{:.input_area}
```R
df_lp_kanto %>% 
  ggplot(aes(floor_area_ratio, building_coverage)) +
  geom_point()

# GGally::ggpairs(df_lp_kanto %>% 
#   select(-starts_with(".")) %>%
#   select_if(is.numeric))

cor(df_lp_kanto$floor_area_ratio, df_lp_kanto$building_coverage)

# mod <- 
#   df_lp_kanto %>% 
#   lm(posted_land_price ~ scale(distance_from_station) + scale(acreage) + scale(night_population),
#      data = .)
car::vif(mod)
```


多重共線性の問題は

明確な数値指標はありませんが、一般にはVIFが10以上の説明変数をモデルに組み込むと多重共線性が発生する可能性があると言われます。

膨大な特徴量に

> LASSOやリッジ回帰のような正則化法は、モデル構築プロセスの一部として特徴の寄与を積極的に削除または割り引くことを積極的に求めているため、特徴量選択を組み込んだアルゴリズムと見なすこともできます。

計算コストを考慮して

## 特徴量選択の方法

<!-- 変数選択ではあっても、モデル選択 ~~とはどういう対応関係?~ ではないかもしれない。
モデルは構築されたもの、モデルで一つ。特徴量選択は個別の特徴量を取り扱う-->

<!-- 半自動的に... 数値による客観的評価。ドメイン知識がなくてOK --> 

モデルの性能評価とともに

モデルに組み込まれた説明変数が目的変数に対してどの程度の影響を持っているのか

特徴量選択の基本的な戦略は次の3つに分かれます。

1. 単変量統計量、フィルタ法 (filter method)... 無関係な特徴,相関の強い変数を削除
2. 反復特徴量選択、ラッパー法 (wrapper method)
3. モデルベース特徴量選択、組み込み法 (emedded method)

このうち単変量統計量による変数選択はモデルを利用しません。その戦略は情報量の少ない変数や、互いに相関のある変数の片方を削るというもので、すでに[データの前処理](01/tidy-data)の段階で触れています。したがってここでは解説を行いません。

単変量統計量は余分な特徴量を減らすことには貢献しますが、モデルの性能向上に対する期待はできないかもしれません。

反復特徴量選択、モデルベース特徴量選択では教師あり学習を利用します。そのため、実行時は[データ分割](03/data-splitting)により分析・評価セットへデータを分割した後、分析セットに対して適用することになります。ここではこの2つの特徴量選択の方法を紹介します。

### 反復特徴量選択

異なる特徴量を用いたモデルを作る

- 前向き法 (Forward stepwise selection)... 
- 後向き法 (Backward stepwise selection)... 関心のある特徴量を含めたモデルを構築。モデルに影響しない不要な特徴を一つずつ消していく

#### 前向き法

回帰モデルを切片のみの状態の値から開始し、順次、推定結果を改善する説明変数を追加していく。

データ件数に対して変数が多くなる p >> Nの状況であっても計算が可能という利点がある。

#### 後向き法

- k個の特徴がある状態から、最も不要な特徴を一つずつ取りのぞく
- N > kのときのみ使用できる

<!-- 止まってしまうよりも色々見るのがベスト？ -->

1. データを分析セット、評価セットに分割する
2. 各リサンプリングに対して
    - 分析セットでの特徴量のランクを評価する
        - 特徴量のうち1つを除いてモデルに当てはめる
        - 評価セットでの評価
3. 各リサンプリングでの性能を平均し、最も良いモデルを選ぶ、訓練データに適用する

### モデルベース特徴量選択

特徴量選択の3つの戦略の中で最も重要になる。

最終的に利用するモデルと異なるモデル、例えば問題が分類問題であっても回帰モデルを利用したり、回帰問題の場合であっても決定木やランダムフォレストを利用しても良いという特徴があります。各モデルで特徴量選択の基準として、木ベースのモデルでは特徴量重要度 (feature importance)、MARSなどの線形モデルでは回帰係数を頼りにすることとなります。

特徴量選択のための手順が完全にモデル構築のプロセスに含められているという利点があります

モデルを利用する特徴量選択では、リサンプリングも行います。


モデルを構築していく段階で個々の特徴量の重要度を数値化

重要だと思われる特徴量のみを残す。



{:.input_area}
```R
library(Boruta)

d <- df_lp_kanto_sp_baked %>% 
  select(-administrative_area_code, -starts_with(".")) %>% 
  verify(ncol(.) == 112L)

# 13 mins.
Bor_lp <- 
  Boruta(posted_land_price ~ ., data = d, doTrace = 2)
Bor_lp
plot(Bor_lp)
# plotImpHistory(Bor_lp)

df_bor_stats <- 
  attStats(Bor_lp) %>% 
  tibble::rownames_to_column() %>% 
  arrange(decision, desc(meanImp))

df_bor_stats %>% 
  count(decision)

df_bor_stats %>% 
  filter(decision == "Confirmed")
```


#### 最初の第一歩としての変数重要度の確認

- 客観的な評価、思わぬ存在を発見できるかもしれない
    - 戦略としてはアリ
    - Kaggle... とりあえずGBMに
    - 思わぬ組み合わせ（新しい特徴量の生成）
- その結果を過大評価、他の変数を捨ててしまうことは避けたい

## まとめ

## 関連項目

- 重回帰分析
- PCA (線形変換系手法)
- t-SNE (非線形)
- 解釈
- [次元削減](03/dimension-reducion)

## 参考文献

- Trevor Hastie, Robert Tibshirani and Jerome Friedman (2009). The Elements of Statistical Learning (**翻訳** 杉山将ほか訳 (2014). 統計的学習の基礎. (共立出版))
- 久保拓弥 (2012). データ解析のための統計モデリング入門 (岩波書店)
- Sarah Guido and Andreas Müller (2016). Introduction to Machine Learning with Python A Guide for Data Scientists (O'Reilly) (**翻訳** 中田秀基訳 (2017). Pythonではじめる機械学習 scikit-learnで学ぶ特徴量エンジニアリングと機械学習の基礎 (オライリー))
- Max Kuhn and Kjell Johnson (2019).[Feature Engineering and Selection: A Practical Approach for Predictive Models](https://bookdown.org/max/FES/) (CRC Press)
