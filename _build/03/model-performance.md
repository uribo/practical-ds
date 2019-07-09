---
interact_link: content/03/model-performance.ipynb
kernel_name: ir
has_widgets: false
title: 'モデルの性能評価'
prev_page:
  url: /03/dimension-reduction
  title: '次元削減'
next_page:
  url: /03/data-splitting
  title: 'データ分割'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---

# モデルの性能評価

## モデルの汎化能力と過学習

## 性能評価指標

タスクに応じた評価指標を利用する

回帰問題と分類問題では異なる評価指標を用いる。

データの性質や評価したい項目に応じてさらに使い分ける。

###　回帰問題

- 決定係数 (coefficient of determination: $R^2$)
- 平均二乗誤差 (MSE)
- 二乗平均平方根誤差 (Root Mean Square Error: RMSE)
- 平均絶対誤差 (Mean Absolute Error: MAE)

- 外れ値が多く含まれる場合にはMAEを検討（外れ値の影響を受けにくい）

#### 決定係数

$$R^2 = 1 - RSS / TSS$$

RSS... 残差平方和
TSS... 全平方和

#### 二乗平均平方根誤差

$$RMSE = \sqrt{\frac{\sum_{i=1}^n (y^{(i)} - {y_{EST}}^{(i)})^2}{n}}$$

### 分類問題

- 正解率
- 混同行列
- 適合率と再現率
- ROC曲線とAUC
