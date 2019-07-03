---
redirect_from:
  - "/01/tidymodels-workflow"
interact_link: content/01/tidymodels_workflow.ipynb
kernel_name: ir
title: 'モデルの構築から評価まで'
prev_page:
  url: /01/tidy_data
  title: 'tidyデータと前処理'
next_page:
  url: /02/readme
  title: '特徴量エンジニアリング'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---



{:.input_area}
```
source(here::here("R/setup.R"))
```


# 分析プロジェクトの全体像を掴む

- データが与えられた
- このデータを使って何を明らかにすることが目的か、またその結果をどのように使い、何を得たいのか
- システム設計
    - 問題を構成します。
    - データの特徴や目的により特定していく

地価公示データ

- 教師付き学習
- 回帰のタスク
    - 多変量回帰

評価指標の選択

- 評価指標...
- 回帰問題での典型的な評価指標は二乗平均平方根誤差 (Root Mean Square Error: RMSE)
    - 外れ値が多く含まれる場合にはMAEを検討（外れ値の影響を受けにくい）

データの分割

- 単純な無作為抽出による分割 (hold-out)
    - データが大規模なら良いが（特に属性の数との関係に注意。属性数がデータ件数よりも多い場合ではよくない。大きなサンプリングバイアスをもたらす恐れがある）
        - 分割可能な層がないか... 層化抽出法を検討

## モデルの構築から評価まで

- モデル構築
    - パラメータを推定する... 訓練用のモデル
    - モデル選択とmodel comparison
    - 新しいデータ（評価データ）による性能測定

仮説を立て、検証し、決定するプロセスを経て変換することが重要（前処理大全）

地価公示データを使います。

前節で見つけたデータの特徴から、いくつかの処理を加えます。

<!-- これはすでに実行させておく??  

# - 評価データは？
# - tidymodelsを使わないパターンも用意したい

-->

<!-- 最終的にselectする変数が決まっているから削除のステップは省略? -->

<!-- 位置情報データの扱いは後でやるのでここでは議論しない。無視する -->

![](../images/modeling-process.png)

<!-- 可視化の重要性や戻ってくることをEDAで解説しているのでこの図は本の内容の交通整理と共に最初で示すのが良いかもしれない --> 

バイアスと分散のトレードオフ

考慮すべきこと

- 過学習への対策としてのデータ分割
- モデルの汎化性能を評価するための指標の選択
- 複数のモデルによる比較
- モデルのハイパーパラメータの探索と調整

## 線形回帰モデルの構築

地価公示データ


<!--最も関連がありそうな変数は何だろう？ 事前にアンケートできるならその結果を使う -->



{:.input_area}
```
ggplot() +
  geom_sf(data = ne_knt, fill = "transparent") +
  geom_sf(data = df_lp_kanto %>% 
            sf::st_as_sf(coords = 
                           c(".longitude", ".latitude"), 
                         crs = 4326),
          size = 0.2,
          alpha = 0.75) +
  coord_sf(datum = NA)
```


- 地価公示データ
- 係数の推定
- データ分割後、性能評価
    - 残差プロット
    - 平均二乗誤差(MSE)、決定係数(R2)




{:.input_area}
```
reg_perf_metrics <- metric_set(rmse, rsq, mae)
```




{:.input_area}
```
df_lp_kanto_simple <- 
  df_lp_kanto %>% 
  dplyr::select(posted_land_price, 
                .longitude,
                .latitude)

glimpse(df_lp_kanto_simple)
```


### データ分割

訓練データとテストデータ

- 訓練データ (training set)... モデルのパラメータ推定に利用される
- テストデータ (test set)... モデルの学習中には利用されない。



{:.input_area}
```
# 訓練データとテストデータ
# [ ] 後の章で空間配置を考慮した分割にする
set.seed(123)
lp_split <- 
  df_lp_kanto_simple %>% 
  initial_split(prop = 3/4)
df_lp_train <- training(lp_split)
df_lp_test <- testing(lp_split)
```


単純なhold-out検証を行う

### 初期モデルの作成

単純な、地価公示標準地の位置（緯度と経度）が価格に影響するというモデルを考えてみます。



{:.input_area}
```
mod_formula <- formula(posted_land_price ~ .longitude + .latitude)
# モデルを定義... 線形回帰モデル
mod_lin_reg <- linear_reg()
# エンジンを指定... stats::lm
spec_lm <- set_engine(mod_lin_reg, engine = "lm")
```




{:.input_area}
```
mod_rec <- 
  df_lp_train %>% 
  recipe(mod_formula) %>% 
  # 対数変換により正規分布に近づける
  step_log(all_outcomes(), base = 10)

mod_rec
```




{:.input_area}
```
df_baked <- 
  mod_rec %>% 
  prep(training = df_lp_train) %>% 
  bake(new_data = df_lp_train)
```




{:.input_area}
```
fit_lm <- 
  fit(
    spec_lm,
    mod_formula,
    data = df_baked)

tidy(fit_lm)
```


### モデル評価



{:.input_area}
```
# predict
test_pred <- 
  fit_lm %>% 
  predict(new_data = df_lp_test) %>% 
  bind_cols(df_lp_test) %>% 
  transmute(log_price = log10(posted_land_price),
            .pred)

test_pred %>% 
  reg_perf_metrics(truth = log_price, estimate = .pred)
```


## まとめ

## 関連項目

- データ分割

## 参考文献

- Aurélien Géron (2017). Hands-On Machine Learning with Scikit-Learn and TensorFlow (O'Reilly) (**翻訳** 長尾高弘訳 (2018). scikit-learnとTensorFlowによる実践機械学習 (オライリー))
- Max Kuhn and Kjell Johnson (2019).[Feature Engineering and Selection: A Practical Approach for Predictive Models](https://bookdown.org/max/FES/) (CRC Press)
