---
interact_link: content/01/eda.ipynb
kernel_name: ir
title: '探索的データ分析'
prev_page:
  url: /01/introduction
  title: 'データ分析のプロセス'
next_page:
  url: /01/tidy_data
  title: 'tidyデータと前処理'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---

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



{:.input_area}
```R
source(here::here("R/setup.R"))
```


### データの大きさ

データフレームは行と列からなります。いくつかの関数を使って読み込んだデータの大きさを調べてみましょう。



{:.input_area}
```R
dim(df_lp_kanto)
```



<div markdown="0" class="output output_html">
<ol class=list-inline>
	<li>7961</li>
	<li>40</li>
</ol>

</div>


`dim()`をデータフレームに適用すると、そのサイズを数値ベクトルで返します。最初の要素が行数、2番目の数字が列数を示します。これは次の`ncol()`、`nrow()`により個別に求めることができます。




{:.input_area}
```R
nrow(df_lp_kanto)
ncol(df_lp_kanto)
```



<div markdown="0" class="output output_html">
7961
</div>



<div markdown="0" class="output output_html">
40
</div>


### データの一部を表示

データフレームの一部を表示して、列名と値の確認をしてみましょう。`head()`をデータフレームに対して実行すると先頭の数行を表示します。また`tail()` でデータフレームの最後の行を表示できます。いずれの関数も引数`n = ` に実数を与えることで表示される行数を制御可能です。



{:.input_area}
```R
head(df_lp_kanto)

tail(df_lp_kanto, n = 3)
```



<div markdown="0" class="output output_html">
<table>
<caption>A tibble: 6 × 40</caption>
<thead>
	<tr><th scope=col>.row_id</th><th scope=col>prefecture</th><th scope=col>administrative_area_code</th><th scope=col>posted_land_price</th><th scope=col>name_of_nearest_station</th><th scope=col>distance_from_station</th><th scope=col>acreage</th><th scope=col>current_use</th><th scope=col>building_structure</th><th scope=col>attribute_change_supplied_facility</th><th scope=col>⋯</th><th scope=col>attribute_change_distance_from_station</th><th scope=col>attribute_change_use_district</th><th scope=col>attribute_change_fire_area</th><th scope=col>attribute_change_urban_planning_area</th><th scope=col>attribute_change_forest_law</th><th scope=col>attribute_change_parks_law</th><th scope=col>attribute_change_building_coverage</th><th scope=col>common_surveyed_position</th><th scope=col>.longitude</th><th scope=col>.latitude</th></tr>
	<tr><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>⋯</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><td>11955</td><td>群馬県</td><td>10426</td><td>39000</td><td>長野原草津口</td><td>13000</td><td>166</td><td>住宅     </td><td>W2</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>138.5921</td><td>36.61913</td></tr>
	<tr><td>11956</td><td>群馬県</td><td>10426</td><td>56800</td><td>長野原草津口</td><td>13000</td><td>226</td><td>店舗     </td><td>W1</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>138.5933</td><td>36.62025</td></tr>
	<tr><td>11965</td><td>群馬県</td><td>10426</td><td>29800</td><td>長野原草津口</td><td>14000</td><td>173</td><td>住宅     </td><td>W2</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>138.6083</td><td>36.62088</td></tr>
	<tr><td>12079</td><td>群馬県</td><td>10211</td><td>24900</td><td>西松井田    </td><td>  950</td><td>112</td><td>住宅,店舗</td><td>W2</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>138.7953</td><td>36.31541</td></tr>
	<tr><td>12086</td><td>群馬県</td><td>10211</td><td>20500</td><td>松井田      </td><td>  750</td><td>264</td><td>住宅     </td><td>W2</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>138.8013</td><td>36.31065</td></tr>
	<tr><td>12103</td><td>群馬県</td><td>10429</td><td>13300</td><td>群馬原町    </td><td> 1400</td><td>329</td><td>住宅     </td><td>W2</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>138.8224</td><td>36.56371</td></tr>
</tbody>
</table>

</div>



<div markdown="0" class="output output_html">
<table>
<caption>A tibble: 3 × 40</caption>
<thead>
	<tr><th scope=col>.row_id</th><th scope=col>prefecture</th><th scope=col>administrative_area_code</th><th scope=col>posted_land_price</th><th scope=col>name_of_nearest_station</th><th scope=col>distance_from_station</th><th scope=col>acreage</th><th scope=col>current_use</th><th scope=col>building_structure</th><th scope=col>attribute_change_supplied_facility</th><th scope=col>⋯</th><th scope=col>attribute_change_distance_from_station</th><th scope=col>attribute_change_use_district</th><th scope=col>attribute_change_fire_area</th><th scope=col>attribute_change_urban_planning_area</th><th scope=col>attribute_change_forest_law</th><th scope=col>attribute_change_parks_law</th><th scope=col>attribute_change_building_coverage</th><th scope=col>common_surveyed_position</th><th scope=col>.longitude</th><th scope=col>.latitude</th></tr>
	<tr><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>⋯</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;lgl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><td>21343</td><td>茨城県</td><td>08232</td><td>15600</td><td>銚子</td><td>3200</td><td>125</td><td>住宅     </td><td>W2</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>140.8311</td><td>35.74772</td></tr>
	<tr><td>21363</td><td>千葉県</td><td>12202</td><td>41200</td><td>銚子</td><td>1800</td><td>119</td><td>住宅,店舗</td><td>S3</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>140.8434</td><td>35.73295</td></tr>
	<tr><td>21375</td><td>千葉県</td><td>12202</td><td>31500</td><td>銚子</td><td>2200</td><td>111</td><td>住宅     </td><td>W2</td><td>FALSE</td><td>⋯</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>FALSE</td><td>140.8480</td><td>35.73405</td></tr>
</tbody>
</table>

</div>


### 各列の情報

データ型や件数、欠損の状況を調べます。



{:.input_area}
```R
glimpse(df_lp_kanto)
```


{:.output .output_stream}
```
Observations: 7,961
Variables: 40
$ .row_id                                [3m[38;5;246m<int>[39m[23m 11955, 11956, 11965, 12079, 1…
$ prefecture                             [3m[38;5;246m<chr>[39m[23m "群馬県", "群馬県", "群馬県", "群馬県", "…
$ administrative_area_code               [3m[38;5;246m<chr>[39m[23m "10426", "10426", "10426", "1…
$ posted_land_price                      [3m[38;5;246m<int>[39m[23m 39000, 56800, 29800, 24900, 2…
$ name_of_nearest_station                [3m[38;5;246m<chr>[39m[23m "長野原草津口", "長野原草津口", "長野原草津口",…
$ distance_from_station                  [3m[38;5;246m<int>[39m[23m 13000, 13000, 14000, 950, 750…
$ acreage                                [3m[38;5;246m<int>[39m[23m 166, 226, 173, 112, 264, 329,…
$ current_use                            [3m[38;5;246m<chr>[39m[23m "住宅", "店舗", "住宅", "住宅,店舗", "住…
$ building_structure                     [3m[38;5;246m<chr>[39m[23m "W2", "W1", "W2", "W2", "W2",…
$ attribute_change_supplied_facility     [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ water_facility                         [3m[38;5;246m<lgl>[39m[23m TRUE, TRUE, TRUE, TRUE, TRUE,…
$ gas_facility                           [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ sewage_facility                        [3m[38;5;246m<lgl>[39m[23m TRUE, TRUE, TRUE, FALSE, FALS…
$ depth_ratio                            [3m[38;5;246m<dbl>[39m[23m 1.0, 2.0, 1.0, 3.0, 1.0, 1.5,…
$ number_of_floors                       [3m[38;5;246m<int>[39m[23m 2, 1, 2, 2, 2, 2, 2, 2, 2, 2,…
$ number_of_basement_floors              [3m[38;5;246m<int>[39m[23m 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
$ use_district                           [3m[38;5;246m<chr>[39m[23m "2住居", "近商", "2住居", "近商", "1住…
$ building_coverage                      [3m[38;5;246m<dbl>[39m[23m 60, 80, 60, 80, 60, 60, 80, 6…
$ configuration                          [3m[38;5;246m<chr>[39m[23m NA, "台形", NA, NA, "台形", "台形",…
$ surrounding_present_usage              [3m[38;5;246m<chr>[39m[23m "一般住宅の中にアパート等が混在する住宅地域", "土産店…
$ fire_area                              [3m[38;5;246m<chr>[39m[23m NA, NA, NA, NA, NA, NA, NA, N…
$ urban_planning_area                    [3m[38;5;246m<chr>[39m[23m "非線引", "非線引", "非線引", "非線引", "…
$ attribute_change_floor_area_ratio      [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ frontage_ratio                         [3m[38;5;246m<dbl>[39m[23m 1.2, 1.0, 1.0, 1.0, 1.2, 1.0,…
$ floor_area_ratio                       [3m[38;5;246m<dbl>[39m[23m 200, 300, 200, 200, 200, 200,…
$ attribute_change_selected_land_status  [3m[38;5;246m<chr>[39m[23m "1", "1", "1", "1", "1", "1",…
$ attribute_change_address               [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, TRUE, FA…
$ attribute_change_acreage               [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_current_use           [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_building_structure    [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_distance_from_station [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_use_district          [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_fire_area             [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_urban_planning_area   [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_forest_law            [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_parks_law             [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ attribute_change_building_coverage     [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ common_surveyed_position               [3m[38;5;246m<lgl>[39m[23m FALSE, FALSE, FALSE, FALSE, F…
$ .longitude                             [3m[38;5;246m<dbl>[39m[23m 138.5921, 138.5933, 138.6083,…
$ .latitude                              [3m[38;5;246m<dbl>[39m[23m 36.61913, 36.62025, 36.62088,…

```

この地価公示データには45の列（変数）があります。

- データの型 (`character`, `numeric`, `logical`, `factor`)
- 欠損数、ユニーク数
- 文字データの長さの幅
- カテゴリデータの偏り、水準、順序
- 数値データの要約統計量、分布（ヒストグラム）

- `configuration`や`fire_area`は欠損を多く含んでいることがわかります。`building_structure`にもわずかですが欠損データがあります




{:.input_area}
```R
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
```R
summary(df_lp_kanto)
```



{:.output .output_data_text}
```
    .row_id       prefecture        administrative_area_code posted_land_price 
 Min.   :11955   Length:7961        Length:7961              Min.   :    5660  
 1st Qu.:14496   Class :character   Class :character         1st Qu.:   74500  
 Median :16488   Mode  :character   Mode  :character         Median :  167000  
 Mean   :16531                                               Mean   :  440857  
 3rd Qu.:18518                                               3rd Qu.:  323000  
 Max.   :21375                                               Max.   :55500000  
 name_of_nearest_station distance_from_station    acreage        
 Length:7961             Min.   :    0         Min.   :    46.0  
 Class :character        1st Qu.:  500         1st Qu.:   136.0  
 Mode  :character        Median :  900         Median :   176.0  
                         Mean   : 1394         Mean   :   748.1  
                         3rd Qu.: 1700         3rd Qu.:   249.0  
                         Max.   :24000         Max.   :413215.0  
 current_use        building_structure attribute_change_supplied_facility
 Length:7961        Length:7961        Mode :logical                     
 Class :character   Class :character   FALSE:7917                        
 Mode  :character   Mode  :character   TRUE :44                          
                                                                         
                                                                         
                                                                         
 water_facility  gas_facility    sewage_facility  depth_ratio   
 Mode :logical   Mode :logical   Mode :logical   Min.   :1.000  
 FALSE:8         FALSE:1401      FALSE:377       1st Qu.:1.000  
 TRUE :7953      TRUE :6560      TRUE :7584      Median :1.500  
                                                 Mean   :1.468  
                                                 3rd Qu.:1.500  
                                                 Max.   :6.500  
 number_of_floors number_of_basement_floors use_district      
 Min.   : 0.000   Min.   :0.00000           Length:7961       
 1st Qu.: 2.000   1st Qu.:0.00000           Class :character  
 Median : 2.000   Median :0.00000           Mode  :character  
 Mean   : 2.782   Mean   :0.08052                             
 3rd Qu.: 3.000   3rd Qu.:0.00000                             
 Max.   :52.000   Max.   :6.00000                             
 building_coverage configuration      surrounding_present_usage
 Min.   :30.00     Length:7961        Length:7961              
 1st Qu.:50.00     Class :character   Class :character         
 Median :60.00     Mode  :character   Mode  :character         
 Mean   :60.38                                                 
 3rd Qu.:60.00                                                 
 Max.   :80.00                                                 
  fire_area         urban_planning_area attribute_change_floor_area_ratio
 Length:7961        Length:7961         Mode :logical                    
 Class :character   Class :character    FALSE:7959                       
 Mode  :character   Mode  :character    TRUE :2                          
                                                                         
                                                                         
                                                                         
 frontage_ratio  floor_area_ratio attribute_change_selected_land_status
 Min.   :1.000   Min.   :  50.0   Length:7961                          
 1st Qu.:1.000   1st Qu.: 100.0   Class :character                     
 Median :1.000   Median : 200.0   Mode  :character                     
 Mean   :1.067   Mean   : 218.6                                        
 3rd Qu.:1.000   3rd Qu.: 200.0                                        
 Max.   :5.500   Max.   :1300.0                                        
 attribute_change_address attribute_change_acreage attribute_change_current_use
 Mode :logical            Mode :logical            Mode :logical               
 FALSE:7899               FALSE:7939               FALSE:7888                  
 TRUE :62                 TRUE :22                 TRUE :73                    
                                                                               
                                                                               
                                                                               
 attribute_change_building_structure attribute_change_distance_from_station
 Mode :logical                       Mode :logical                         
 FALSE:7893                          FALSE:7918                            
 TRUE :68                            TRUE :43                              
                                                                           
                                                                           
                                                                           
 attribute_change_use_district attribute_change_fire_area
 Mode :logical                 Mode :logical             
 FALSE:7960                    FALSE:7902                
 TRUE :1                       TRUE :59                  
                                                         
                                                         
                                                         
 attribute_change_urban_planning_area attribute_change_forest_law
 Mode :logical                        Mode :logical              
 FALSE:7960                           FALSE:7961                 
 TRUE :1                                                         
                                                                 
                                                                 
                                                                 
 attribute_change_parks_law attribute_change_building_coverage
 Mode :logical              Mode :logical                     
 FALSE:7961                 FALSE:7959                        
                            TRUE :2                           
                                                              
                                                              
                                                              
 common_surveyed_position   .longitude      .latitude    
 Mode :logical            Min.   :138.6   Min.   :34.98  
 FALSE:7357               1st Qu.:139.5   1st Qu.:35.59  
 TRUE :604                Median :139.7   Median :35.71  
                          Mean   :139.7   Mean   :35.77  
                          3rd Qu.:139.9   3rd Qu.:35.88  
                          Max.   :140.8   Max.   :37.02  
```


Rの組み込み関数として用意されている `summary()` を利用して、データフレームに含まれる列の要約統計量を得ることができます。



{:.input_area}
```R
# 論理値型で標準偏差0の列を特定 constant cols
df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is.logical) %>% 
  mutate_all(as.numeric) %>% 
  summarise_all(sd) %>% 
  tidyr::gather()
```



<div markdown="0" class="output output_html">
<table>
<caption>A tibble: 17 × 2</caption>
<thead>
	<tr><th scope=col>key</th><th scope=col>value</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><td>attribute_change_supplied_facility    </td><td>0.07414234</td></tr>
	<tr><td>water_facility                        </td><td>0.03168620</td></tr>
	<tr><td>gas_facility                          </td><td>0.38082955</td></tr>
	<tr><td>sewage_facility                       </td><td>0.21241222</td></tr>
	<tr><td>attribute_change_floor_area_ratio     </td><td>0.01584907</td></tr>
	<tr><td>attribute_change_address              </td><td>0.08791066</td></tr>
	<tr><td>attribute_change_acreage              </td><td>0.05249935</td></tr>
	<tr><td>attribute_change_current_use          </td><td>0.09532450</td></tr>
	<tr><td>attribute_change_building_structure   </td><td>0.09203122</td></tr>
	<tr><td>attribute_change_distance_from_station</td><td>0.07329960</td></tr>
	<tr><td>attribute_change_use_district         </td><td>0.01120769</td></tr>
	<tr><td>attribute_change_fire_area            </td><td>0.08577371</td></tr>
	<tr><td>attribute_change_urban_planning_area  </td><td>0.01120769</td></tr>
	<tr><td>attribute_change_forest_law           </td><td>0.00000000</td></tr>
	<tr><td>attribute_change_parks_law            </td><td>0.00000000</td></tr>
	<tr><td>attribute_change_building_coverage    </td><td>0.01584907</td></tr>
	<tr><td>common_surveyed_position              </td><td>0.26480641</td></tr>
</tbody>
</table>

</div>


ここでは `skimr::` で行う例を示します。



{:.input_area}
```R
# skimr::skim(df_lp) # Rコンソールでの実行は skim() で構いません
df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  skimr::skim_to_list()
```



<div markdown="0" class="output output_html">
<dl>
	<dt>$character</dt>
		<dd><table>
<caption>A tbl: 11 × 8</caption>
<thead>
	<tr><th scope=col>variable</th><th scope=col>missing</th><th scope=col>complete</th><th scope=col>n</th><th scope=col>min</th><th scope=col>max</th><th scope=col>empty</th><th scope=col>n_unique</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><td>administrative_area_code             </td><td>0   </td><td>7961</td><td>7961</td><td>5 </td><td>5 </td><td>0</td><td>317 </td></tr>
	<tr><td>attribute_change_selected_land_status</td><td>0   </td><td>7961</td><td>7961</td><td>1 </td><td>1 </td><td>0</td><td>3   </td></tr>
	<tr><td>building_structure                   </td><td>189 </td><td>7772</td><td>7961</td><td>2 </td><td>8 </td><td>0</td><td>130 </td></tr>
	<tr><td>configuration                        </td><td>7087</td><td>874 </td><td>7961</td><td>2 </td><td>3 </td><td>0</td><td>2   </td></tr>
	<tr><td>current_use                          </td><td>0   </td><td>7961</td><td>7961</td><td>2 </td><td>14</td><td>0</td><td>69  </td></tr>
	<tr><td>fire_area                            </td><td>4344</td><td>3617</td><td>7961</td><td>2 </td><td>2 </td><td>0</td><td>2   </td></tr>
	<tr><td>name_of_nearest_station              </td><td>0   </td><td>7961</td><td>7961</td><td>1 </td><td>14</td><td>0</td><td>1424</td></tr>
	<tr><td>prefecture                           </td><td>0   </td><td>7961</td><td>7961</td><td>3 </td><td>4 </td><td>0</td><td>7   </td></tr>
	<tr><td>surrounding_present_usage            </td><td>0   </td><td>7961</td><td>7961</td><td>15</td><td>22</td><td>0</td><td>4047</td></tr>
	<tr><td>urban_planning_area                  </td><td>0   </td><td>7961</td><td>7961</td><td>2 </td><td>3 </td><td>0</td><td>3   </td></tr>
	<tr><td>use_district                         </td><td>0   </td><td>7961</td><td>7961</td><td>2 </td><td>3 </td><td>0</td><td>12  </td></tr>
</tbody>
</table>
</dd>
	<dt>$integer</dt>
		<dd><table>
<caption>A tbl: 5 × 12</caption>
<thead>
	<tr><th scope=col>variable</th><th scope=col>missing</th><th scope=col>complete</th><th scope=col>n</th><th scope=col>mean</th><th scope=col>sd</th><th scope=col>p0</th><th scope=col>p25</th><th scope=col>p50</th><th scope=col>p75</th><th scope=col>p100</th><th scope=col>hist</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><td>acreage                  </td><td>0</td><td>7961</td><td>7961</td><td>   748.05 </td><td>   7468.15</td><td>46  </td><td>136  </td><td>176   </td><td>249   </td><td>413215  </td><td>▇▁▁▁▁▁▁▁</td></tr>
	<tr><td>distance_from_station    </td><td>0</td><td>7961</td><td>7961</td><td>  1393.74 </td><td>   1711.62</td><td>0   </td><td>500  </td><td>900   </td><td>1700  </td><td>24000   </td><td>▇▁▁▁▁▁▁▁</td></tr>
	<tr><td>number_of_basement_floors</td><td>0</td><td>7961</td><td>7961</td><td>     0.081</td><td>      0.34</td><td>0   </td><td>0    </td><td>0     </td><td>0     </td><td>6       </td><td>▇▁▁▁▁▁▁▁</td></tr>
	<tr><td>number_of_floors         </td><td>0</td><td>7961</td><td>7961</td><td>     2.78 </td><td>      2.27</td><td>0   </td><td>2    </td><td>2     </td><td>3     </td><td>52      </td><td>▇▁▁▁▁▁▁▁</td></tr>
	<tr><td>posted_land_price        </td><td>0</td><td>7961</td><td>7961</td><td>440856.77 </td><td>1819677.45</td><td>5660</td><td>74500</td><td>167000</td><td>323000</td><td>55500000</td><td>▇▁▁▁▁▁▁▁</td></tr>
</tbody>
</table>
</dd>
	<dt>$logical</dt>
		<dd><table>
<caption>A tbl: 17 × 6</caption>
<thead>
	<tr><th scope=col>variable</th><th scope=col>missing</th><th scope=col>complete</th><th scope=col>n</th><th scope=col>mean</th><th scope=col>count</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><td>attribute_change_acreage              </td><td>0</td><td>7961</td><td>7961</td><td>0.0028 </td><td>FAL: 7939, TRU: 22, NA: 0  </td></tr>
	<tr><td>attribute_change_address              </td><td>0</td><td>7961</td><td>7961</td><td>0.0078 </td><td>FAL: 7899, TRU: 62, NA: 0  </td></tr>
	<tr><td>attribute_change_building_coverage    </td><td>0</td><td>7961</td><td>7961</td><td>0.00025</td><td>FAL: 7959, TRU: 2, NA: 0   </td></tr>
	<tr><td>attribute_change_building_structure   </td><td>0</td><td>7961</td><td>7961</td><td>0.0085 </td><td>FAL: 7893, TRU: 68, NA: 0  </td></tr>
	<tr><td>attribute_change_current_use          </td><td>0</td><td>7961</td><td>7961</td><td>0.0092 </td><td>FAL: 7888, TRU: 73, NA: 0  </td></tr>
	<tr><td>attribute_change_distance_from_station</td><td>0</td><td>7961</td><td>7961</td><td>0.0054 </td><td>FAL: 7918, TRU: 43, NA: 0  </td></tr>
	<tr><td>attribute_change_fire_area            </td><td>0</td><td>7961</td><td>7961</td><td>0.0074 </td><td>FAL: 7902, TRU: 59, NA: 0  </td></tr>
	<tr><td>attribute_change_floor_area_ratio     </td><td>0</td><td>7961</td><td>7961</td><td>0.00025</td><td>FAL: 7959, TRU: 2, NA: 0   </td></tr>
	<tr><td>attribute_change_forest_law           </td><td>0</td><td>7961</td><td>7961</td><td>0      </td><td>FAL: 7961, NA: 0           </td></tr>
	<tr><td>attribute_change_parks_law            </td><td>0</td><td>7961</td><td>7961</td><td>0      </td><td>FAL: 7961, NA: 0           </td></tr>
	<tr><td>attribute_change_supplied_facility    </td><td>0</td><td>7961</td><td>7961</td><td>0.0055 </td><td>FAL: 7917, TRU: 44, NA: 0  </td></tr>
	<tr><td>attribute_change_urban_planning_area  </td><td>0</td><td>7961</td><td>7961</td><td>0.00013</td><td>FAL: 7960, TRU: 1, NA: 0   </td></tr>
	<tr><td>attribute_change_use_district         </td><td>0</td><td>7961</td><td>7961</td><td>0.00013</td><td>FAL: 7960, TRU: 1, NA: 0   </td></tr>
	<tr><td>common_surveyed_position              </td><td>0</td><td>7961</td><td>7961</td><td>0.076  </td><td>FAL: 7357, TRU: 604, NA: 0 </td></tr>
	<tr><td>gas_facility                          </td><td>0</td><td>7961</td><td>7961</td><td>0.82   </td><td>TRU: 6560, FAL: 1401, NA: 0</td></tr>
	<tr><td>sewage_facility                       </td><td>0</td><td>7961</td><td>7961</td><td>0.95   </td><td>TRU: 7584, FAL: 377, NA: 0 </td></tr>
	<tr><td>water_facility                        </td><td>0</td><td>7961</td><td>7961</td><td>1      </td><td>TRU: 7953, FAL: 8, NA: 0   </td></tr>
</tbody>
</table>
</dd>
	<dt>$numeric</dt>
		<dd><table>
<caption>A tbl: 4 × 12</caption>
<thead>
	<tr><th scope=col>variable</th><th scope=col>missing</th><th scope=col>complete</th><th scope=col>n</th><th scope=col>mean</th><th scope=col>sd</th><th scope=col>p0</th><th scope=col>p25</th><th scope=col>p50</th><th scope=col>p75</th><th scope=col>p100</th><th scope=col>hist</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
	<tr><td>building_coverage</td><td>0</td><td>7961</td><td>7961</td><td> 60.38</td><td> 12.21</td><td>30</td><td>50 </td><td> 60  </td><td> 60  </td><td>  80  </td><td>▁▂▁▃▇▁▁▃</td></tr>
	<tr><td>depth_ratio      </td><td>0</td><td>7961</td><td>7961</td><td>  1.47</td><td>  0.55</td><td>1 </td><td>1  </td><td>  1.5</td><td>  1.5</td><td>   6.5</td><td>▇▂▁▁▁▁▁▁</td></tr>
	<tr><td>floor_area_ratio </td><td>0</td><td>7961</td><td>7961</td><td>218.63</td><td>145.24</td><td>50</td><td>100</td><td>200  </td><td>200  </td><td>1300  </td><td>▇▁▁▁▁▁▁▁</td></tr>
	<tr><td>frontage_ratio   </td><td>0</td><td>7961</td><td>7961</td><td>  1.07</td><td>  0.21</td><td>1 </td><td>1  </td><td>  1  </td><td>  1  </td><td>   5.5</td><td>▇▁▁▁▁▁▁▁</td></tr>
</tbody>
</table>
</dd>
</dl>

</div>


論理型データのうち、`attribute_change_forest_law` と `attribute_change_parks_law` は FALSE のみが出現していることがわかります。

## 探索的データ分析

モデリングでは、目的変数の挙動（予測、分類）を明らかにすることがゴールとして設定されます。変数が多いデータであるほど確認する図の数が多くなり、効率的ではなくなります。そのため、まずはモデリングの目的変数となるデータを詳しく見ることを勧めます。また、この段階で作る図は初期モデルを構築する前段階で示唆を提供するものであると望ましいです。そこで目的変数に影響する説明変数、説明変数間の関係を明らかにすることで、次のモデリングプロセスに活かせる知識を得られることが期待できます。

探索的データ分析の結果が最終的な成果物になることは稀です。ここで作られる図は論文や書籍、プレゼンテーションのための図ではありません。つまり複雑な図を作ることは求められていません。ここでは主にggplot2による作図を行いますが、扱いに慣れた最低限の機能を提供しれくれるライブラリを利用すると良いでしょう。

以下では引き続き、地価公示データを使います。このデータには位置情報も含まれているため、地図上へのデータのマッピングも試みます。

また時系列データの例としてビールへの支出データも利用します。


## 数値データ



{:.input_area}
```R
df_is_num <- 
  df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is_numeric)
```


## カテゴリデータ



{:.input_area}
```R
df_is_cat <- 
  df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is.character) %>% 
  verify(ncol(.) == 13)
```




{:.input_area}
```R
df_is_cat %>% 
  count(name_of_nearest_station, sort = TRUE)
```



<div markdown="0" class="output output_html">
<table>
<caption>A tibble: 1424 × 2</caption>
<thead>
	<tr><th scope=col>name_of_nearest_station</th><th scope=col>n</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
	<tr><td>本厚木    </td><td>54</td></tr>
	<tr><td>平塚      </td><td>49</td></tr>
	<tr><td>宇都宮    </td><td>48</td></tr>
	<tr><td>水戸      </td><td>48</td></tr>
	<tr><td>八王子    </td><td>47</td></tr>
	<tr><td>川崎      </td><td>40</td></tr>
	<tr><td>柏        </td><td>40</td></tr>
	<tr><td>木更津    </td><td>34</td></tr>
	<tr><td>千葉      </td><td>33</td></tr>
	<tr><td>大宮      </td><td>33</td></tr>
	<tr><td>戸塚      </td><td>31</td></tr>
	<tr><td>三鷹      </td><td>31</td></tr>
	<tr><td>逗子      </td><td>31</td></tr>
	<tr><td>前橋      </td><td>31</td></tr>
	<tr><td>橋本      </td><td>29</td></tr>
	<tr><td>茅ケ崎    </td><td>28</td></tr>
	<tr><td>君津      </td><td>28</td></tr>
	<tr><td>古河      </td><td>28</td></tr>
	<tr><td>東武宇都宮</td><td>28</td></tr>
	<tr><td>熊谷      </td><td>27</td></tr>
	<tr><td>土浦      </td><td>27</td></tr>
	<tr><td>小山      </td><td>26</td></tr>
	<tr><td>秦野      </td><td>25</td></tr>
	<tr><td>蕨        </td><td>25</td></tr>
	<tr><td>五井      </td><td>24</td></tr>
	<tr><td>川口      </td><td>24</td></tr>
	<tr><td>太田      </td><td>23</td></tr>
	<tr><td>本八幡    </td><td>23</td></tr>
	<tr><td>稲毛      </td><td>22</td></tr>
	<tr><td>高崎      </td><td>22</td></tr>
	<tr><td>⋮</td><td>⋮</td></tr>
	<tr><td>舞岡        </td><td>1</td></tr>
	<tr><td>風祭        </td><td>1</td></tr>
	<tr><td>福浦        </td><td>1</td></tr>
	<tr><td>片瀬江ノ島  </td><td>1</td></tr>
	<tr><td>宝町        </td><td>1</td></tr>
	<tr><td>北鹿沼      </td><td>1</td></tr>
	<tr><td>北習志野    </td><td>1</td></tr>
	<tr><td>北真岡      </td><td>1</td></tr>
	<tr><td>北水海道    </td><td>1</td></tr>
	<tr><td>北藤岡      </td><td>1</td></tr>
	<tr><td>北府中      </td><td>1</td></tr>
	<tr><td>堀切        </td><td>1</td></tr>
	<tr><td>本所吾妻橋  </td><td>1</td></tr>
	<tr><td>本蓮沼      </td><td>1</td></tr>
	<tr><td>茂林寺前    </td><td>1</td></tr>
	<tr><td>木場        </td><td>1</td></tr>
	<tr><td>門沢橋      </td><td>1</td></tr>
	<tr><td>野崎        </td><td>1</td></tr>
	<tr><td>野州大塚    </td><td>1</td></tr>
	<tr><td>野島公園    </td><td>1</td></tr>
	<tr><td>柳小路      </td><td>1</td></tr>
	<tr><td>柳瀬川      </td><td>1</td></tr>
	<tr><td>友部        </td><td>1</td></tr>
	<tr><td>立会川      </td><td>1</td></tr>
	<tr><td>緑が丘      </td><td>1</td></tr>
	<tr><td>六本木一丁目</td><td>1</td></tr>
	<tr><td>和戸        </td><td>1</td></tr>
	<tr><td>和泉多摩川  </td><td>1</td></tr>
	<tr><td>楡木        </td><td>1</td></tr>
	<tr><td>茗荷谷      </td><td>1</td></tr>
</tbody>
</table>

</div>


## 論理値



{:.input_area}
```R
df_is_log <-
  df_lp_kanto %>% 
  select(-starts_with(".")) %>% 
  select_if(is.logical) %>% 
  verify(ncol(.) == 17)
```




{:.input_area}
```R
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
```R
df_is_cat %>% 
  filter(stringr::str_detect(administrative_area_code, "^08")) %>% 
  gg_count_var(name_of_nearest_station)
```


{:.output .output_traceback_line}
```

    Error in df_is_cat %>% filter(stringr::str_detect(administrative_area_code, : could not find function "%>%"
    Traceback:



```



{:.input_area}
```R
purrr::map(
  rlang::syms(names(df_is_cat)),
  ~ gg_count_var(df_is_cat %>% 
                     filter(stringr::str_detect(administrative_area_code, "^08")), 
                 !!.x))
```


### 全体



{:.input_area}
```R
vis_dat(df_lp_kanto)
```



{:.output .output_png}
![png](../images/01/eda_31_0.png)



### 1変数の可視化

データのばらつきを見るのにはヒストグラム、箱ひげ図を利用します。一変量を対象とした単純な可視化は、変数の変動、特性を理解するのに役立ちます。

#### ヒストグラム

スパイク（峰）を検出するのに効果的です。ヒストグラムは単峰、二峰など多様な形状を取り得ます。



{:.input_area}
```R
df_lp_kanto %>% 
  ggplot(aes(posted_land_price)) +
  geom_histogram(bins = 30)
```



{:.output .output_png}
![png](../images/01/eda_33_0.png)



<!-- box-cox変換をする図をあとで -->



{:.input_area}
```R
df_lp_kanto %>% 
  ggplot(aes(posted_land_price)) +
  geom_density() +
  facet_wrap(~ .prefecture, ncol = 1)
```




{:.input_area}
```R
library(ggridges)

ggplot(df_lp_kanto, 
       aes(x = posted_land_price, y  = .prefecture)) +
  scale_x_log10() +
  ggridges::geom_density_ridges(scale = 4)
```


#### 箱ひげ図・バイオリンプロット

### 2変数の可視化




{:.input_area}
```R
df_lp_kanto %>% 
  ggplot(aes(use_district, posted_land_price)) +
  geom_boxplot()
```



{:.output .output_png}
![png](../images/01/eda_39_0.png)



#### 散布図



{:.input_area}
```R
df_lp_kanto %>% 
  ggplot(aes(distance_from_station, posted_land_price)) +
  geom_point()
```



{:.output .output_png}
![png](../images/01/eda_41_0.png)





{:.input_area}
```R
df_lp_kanto %>% 
  ggplot(aes(distance_from_station, acreage)) +
  geom_point()
```



{:.output .output_png}
![png](../images/01/eda_42_0.png)



## 特殊なデータの視覚化

### 時系列データ

時系列データを扱うときは、時間のならびの通りに表示させることが肝心です。周期があるものは分割したり重ねてみると良いでしょう。



{:.input_area}
```R
df_beer2018q2 %>% 
  ggplot(aes(date, expense)) +
  geom_point() +
  geom_line() +
  scale_x_date(date_breaks = "7 days")
```



{:.output .output_png}
![png](../images/01/eda_44_0.png)





{:.input_area}
```R
df_beer2018q2 %>% 
  ggplot(aes(expense)) +
  geom_histogram(bins = 30)
```



{:.output .output_png}
![png](../images/01/eda_45_0.png)



### 空間データ



{:.input_area}
```R
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
```R
df_is_num %>% 
  GGally::ggpairs()

df_is_num %>% 
  corrr::correlate()
```



<div markdown="0" class="output output_html">
<table>
<caption>A cor_df: 9 × 10</caption>
<thead>
	<tr><th scope=col>rowname</th><th scope=col>posted_land_price</th><th scope=col>distance_from_station</th><th scope=col>acreage</th><th scope=col>depth_ratio</th><th scope=col>number_of_floors</th><th scope=col>number_of_basement_floors</th><th scope=col>building_coverage</th><th scope=col>frontage_ratio</th><th scope=col>floor_area_ratio</th></tr>
	<tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
	<tr><td>posted_land_price        </td><td>          NA</td><td>-0.12569556</td><td> 0.008325032</td><td> 0.035318432</td><td> 0.43575145</td><td> 0.54212619</td><td> 0.219008524</td><td> 0.05208925</td><td> 0.475119082</td></tr>
	<tr><td>distance_from_station    </td><td>-0.125695563</td><td>         NA</td><td> 0.055539845</td><td>-0.058296485</td><td>-0.22518578</td><td>-0.14142070</td><td>-0.223526922</td><td>-0.01190656</td><td>-0.247763455</td></tr>
	<tr><td>acreage                  </td><td> 0.008325032</td><td> 0.05553984</td><td>          NA</td><td> 0.007448354</td><td>-0.01239013</td><td> 0.01656375</td><td> 0.005623651</td><td> 0.04439868</td><td> 0.009836352</td></tr>
	<tr><td>depth_ratio              </td><td> 0.035318432</td><td>-0.05829648</td><td> 0.007448354</td><td>          NA</td><td> 0.09296341</td><td> 0.04112338</td><td> 0.275825237</td><td>-0.27393794</td><td> 0.218882108</td></tr>
	<tr><td>number_of_floors         </td><td> 0.435751449</td><td>-0.22518578</td><td>-0.012390130</td><td> 0.092963407</td><td>         NA</td><td> 0.54821812</td><td> 0.486307961</td><td> 0.08079867</td><td> 0.692709498</td></tr>
	<tr><td>number_of_basement_floors</td><td> 0.542126188</td><td>-0.14142070</td><td> 0.016563753</td><td> 0.041123382</td><td> 0.54821812</td><td>         NA</td><td> 0.276671976</td><td> 0.04071109</td><td> 0.495451275</td></tr>
	<tr><td>building_coverage        </td><td> 0.219008524</td><td>-0.22352692</td><td> 0.005623651</td><td> 0.275825237</td><td> 0.48630796</td><td> 0.27667198</td><td>          NA</td><td> 0.03729320</td><td> 0.804167426</td></tr>
	<tr><td>frontage_ratio           </td><td> 0.052089252</td><td>-0.01190656</td><td> 0.044398678</td><td>-0.273937938</td><td> 0.08079867</td><td> 0.04071109</td><td> 0.037293202</td><td>         NA</td><td> 0.057795901</td></tr>
	<tr><td>floor_area_ratio         </td><td> 0.475119082</td><td>-0.24776345</td><td> 0.009836352</td><td> 0.218882108</td><td> 0.69270950</td><td> 0.49545127</td><td> 0.804167426</td><td> 0.05779590</td><td>          NA</td></tr>
</tbody>
</table>

</div>



{:.output .output_png}
![png](../images/01/eda_50_1.png)





{:.input_area}
```R
df_is_num %>% 
  vis_cor()

df_is_log %>% 
  mutate_all(as.numeric) %>% 
  vis_cor()

all.equal(
  df_lp_kanto$attribute_change_building_coverage,
  df_lp_kanto$attribute_change_floor_area_ratio)
```


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
