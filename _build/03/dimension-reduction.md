---
interact_link: content/03/dimension-reduction.ipynb
kernel_name: ir
title: '次元削減'
prev_page:
  url: /03/handling-missing-data
  title: '欠損値の処理'
next_page:
  url: /03/model-performance
  title: 'モデルの性能評価'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---

# 次元削減



{:.input_area}
```R
source(here::here("R/setup.R"))
```


対数変換やBox-Cox変換などが単一のベクトルに対する特徴量エンジニアリングであったのに対し、ここで紹介する方法はモデルベースのアプローチになります。

<!-- 特徴量の作成の文脈でも。外れ値や共線性の問題を考慮 -->

高次元データと呼ぶことがあります。

これらのデータの問題として以下にあげるものがあります

- 計算時間の増加
- 予測性能の低下
- 変数重要度評価の複雑化

ref) `feature-selection`

PCAやMDSなど入力に対して線形変換を行う線形変換の

他、

t-SNE

## 主成分分析

<!-- 欠損値補完が先... handling-missing-data -->

主成分分析 (Principal Component Analysis: PCA) は

特徴空間

主成分と呼ばれる

特徴空間に含まれる情報を要約した特徴量を生成することが期待されます。

主成分分析では、高次元な空間において個々のデータを表現するために「距離」を利用します。

特徴空間上では異なるスケールのデータが混ざることになります。そのため主成分分析を行う際には入力に使う変数を標準化しておく必要があります。

分散が最大となる

主成分を特徴量として利用できます。

主成分軸の寄与率を考慮して、主成分軸の何軸までを利用するか考えます。目安として寄与率が80%~90%あればデータの傾向を説明できると言われます。そのため、第一の基準として累積寄与率が90%となるまでの主成分軸上の得点、すなわち主成分得点を特徴量として扱うことが考えられます。

個々のデータの情報を可能な限り失わないよう、データ全体の関係を要約してくれます。

また、直行する主成分同士は

無相関になるため、

相関のある変数を圧縮するのにも効率的です。
さらに白色化と組み合わせて...
標準化することも



{:.input_area}
```R
# ggplot2 PCで塗り分ける

```





## 部分最小二乗法

- 入力変数だけでなく、目的変数も使用する

## LSA (?)

違うような...

## まとめ

## 参考文献

- Trevor Hastie, Robert Tibshirani and Jerome Friedman (2009). The Elements of Statistical Learning (**翻訳** 統計的学習の基礎. (共立出版))
