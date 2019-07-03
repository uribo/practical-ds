import pandas as pd
from sklearn.preprocessing import StandardScaler
import rootpath

df_landprice = pd.read_csv(
  rootpath.detect() + '/data-raw/landprice_kanto.csv'
)
df_landprice.dtypes

transformer = StandardScaler()

# 変換する。
X_scaled = transformer.fit_transform(X)

from sklearn import datasets, model_selection
from sklearn.ensemble import GradientBoostingClassifier

iris = datasets.load_iris()
iris_data = pd.DataFrame(data=iris.data, columns=iris.feature_names)
iris_label = pd.Series(data=iris.target)
X_train, X_test, y_train, y_test = model_selection.train_test_split(iris_data, iris_label)

clf = GradientBoostingClassifier(random_state=0)
clf.fit(X_train, y_train)

y_pred = clf.predict(X_test)
y_pred
