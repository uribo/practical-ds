import pandas as pd
import rootpath

df_landprice = pd.read_csv(
  rootpath.detect() + '/data-raw/landprice_kanto.csv'
)

from sklearn.datasets import load_iris
iris_dataset = load_iris()
from sklearn.model_selection import train_test_split

X_train, X_test, y_train, y_test = train_test_split(
        iris_dataset['data'], iris_dataset['target'], random_state=0)
