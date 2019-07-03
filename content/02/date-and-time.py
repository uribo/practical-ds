import pandas as pd
import datatable as dt
from datetime import datetime
import rootpath

dt_beer = dt.fread(rootpath.detect() + '/data-raw/beer.csv')
# dt_beer.mode
df_beer = dt_beer.to_pandas()
# df_beer.info()
# 
# 
# year = lambda x: datetime.strptime(x, "%Y-%m-%d" ).year
# month = lambda x: datetime.strptime(x, "%Y-%m-%d" ).month
# day = lambda x: datetime.strptime(x, "%Y-%m-%d" ).day
# 
# df_beer['year'] = df_beer['date'].map(year)
# df_beer['month'] = df_beer['date'].map(month)
# df_beer['day'] = df_beer['date'].map(day)
# 
# df_beer.head()

df_beer = df_beer.set_index('date')

# Indexを指定する
df_beer2018q2 = pd.read_csv(rootpath.detect() + '/data-raw/beer2018q2.csv', 
                            index_col=['date'], 
                            parse_dates=['date'])
df_beer2018q2.head()
df_beer2018q2.index
df_beer2018q2.shape
df_beer2018q2.dtypes

df_beer2018q2.index.year
df_beer2018q2.index.month
df_beer2018q2.index.day
methods(pd)

...
# jpholiday
...
import jpholiday
import datetime
df_beer2018q2["date"] = pd.DatetimeIndex(df_beer2018q2.index).date
df_beer2018q2['is_holiday'] = df_beer2018q2['date'].map(jpholiday.is_holiday).astype(int)
df_beer2018q2.head()


# Visualization
import matplotlib.pyplot as plt
def plot_df(df, x, y, title="", xlabel='Date', ylabel='Value', dpi=100):
    plt.figure(figsize=(16,5), dpi=dpi)
    plt.plot(x, y, color='tab:red')
    plt.gca().set(title=title, xlabel=xlabel, ylabel=ylabel)
    plt.show()

plot_df(df_beer2018q2, 
        x=df_beer2018q2.index, 
        y=df_beer2018q2.expense)
plot_df(df_beer, 
        x=df_beer.index, 
        y=df_beer.expense)

