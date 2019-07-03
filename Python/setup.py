# Python3
import pandas as pd
import datatable as dt
from pathlib import *
import rootpath


'''
データセット1: 地価
'''
df_landprice = pd.read_csv(
  rootpath.detect() + '/data-raw/landprice_kanto.csv'
)
df_landprice.dtypes

# dt_lp_kanto = dt.fread(rootpath.detect() + '/data-raw/landprice_kanto.csv')
# dt_lp_kanto[:, '.prefecture']
# dt_lp_kanto.mode

'''
データセット2: ハザード
'''
df_hazard = pd.read_csv(
  Path('data-raw/hazard.csv'),
  dtype = {'prefectureName': 'object', 'cityName': 'object', 
           'hazardDate': 'object', 'hazardType_sub': 'object', 
           'maxRainfallFor_24h': 'float64', 'maxRainfall_h': 'float64',
           'inclination': 'object', 
           'outflowSediment_m3': 'float64', 'landslideLength_m': 'float64',
           'meshCode': 'object'},
  parse_dates=['hazardDate'])
df_hazard.dtypes
df_hazard.head(3)

'''
データセット3: ビール
'''
df_beer = pd.read_csv(Path('data-raw/beer.csv'))
# # df_beer.size
# # df_beer.dtypes
# # df_beer.info
# 
# df_beer['date'] = pd.to_datetime(df_beer['date'])
# df_beer['date'] = df_beer['date'].dt.date
# 
# print(df_beer.head(3))
# df_beer['date'] = pd.to_datetime(df_beer['date'], format='%Y-%m-%d')
# df_beer['date'][0] - df_beer['date'][1]

# 列の型を指定して読みこむ
df_beer = pd.read_csv(
  Path('data-raw/beer.csv'), 
  dtype={'date': 'object', 'expense': 'float64'}, 
  parse_dates=['date'])

# df_beer['date'].dt.year[0:4]
# df_beer['date'].dt.month[0:4]
# df_beer['date'].dt.day[0:4]
# df_beer['date'].dt.dayofweek[0:5] # 月曜始まり (0)
# df_beer['date'].dt.strftime('%A')[0:5] # %aだと省略形
