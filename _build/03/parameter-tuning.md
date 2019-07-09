---
interact_link: content/03/parameter-tuning.ipynb
kernel_name: ir
has_widgets: false
title: 'ハイパーパラメータの調整'
prev_page:
  url: /03/feature-selection
  title: '変数重要度'
next_page:
  url: /03/interpretability
  title: 'モデルの解釈'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---



{:.input_area}
```
source(here::here("R/setup.R"))
```


# ハイパーパラメータの調整

モデルのパラメータはモデルの外部にあり、データからは推定できない。
用意された初期値や経験則、試行錯誤によって最適値を見出す

機械学習モデルの全体的な動作を制御するため、非常に重要
事前に定義された損失関数を最小化する

ハイパーパラメータの組み合わせを見つける
然もなくば、モデルが収束して損失関数を効率的に最小化できないことで良い結果が得られない

(Kaggleではより良い性能のモデルを求められるが、実用的には最適化は突き詰める必要がないかもしれない... 時間とのトレードオフ。特徴量を磨き上げる方が重要)

