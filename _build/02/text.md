---
interact_link: content/02/text.ipynb
kernel_name: ir
title: 'テキストデータの取り扱い'
prev_page:
  url: /02/categorical
  title: 'カテゴリデータの取り扱い'
next_page:
  url: /02/date-and-time
  title: '日付・時間データの取り扱い'
comment: "***PROGRAMMATICALLY GENERATED, DO NOT EDIT. SEE ORIGINAL FILES IN /content***"
---



{:.input_area}
```R
source(here::here("R/setup.R"))
library(textrecipes)
```


# テキストデータの取り扱い


カテゴリを参照

カテゴリより長く、基本的にユニークな値をもつものを扱う

周辺の土地利用の状況が記載されたs`surrounding_present_usage`を例に示します。 

```{r}
na.omit(df_lp_kanto$surrounding_present_usage)[seq_len(10)]
```

```{r}
df_lp_surrounding_present_usage_count <- 
  df_lp_kanto %>% 
  count(surrounding_present_usage, sort = TRUE)

nrow(df_lp_surrounding_present_usage_count)

df_lp_surrounding_present_usage_count
```

```{r}
df_lp_surrounding_present_usage_count %>% 
  ggplot(aes(n)) +
  geom_density()
```


## テキストの前処理

### ユニコード正規化

```{r}
df_lp_kanto %>% 
  filter(str_detect(surrounding_present_usage, "ＩＣ")) %>% 
  pull(surrounding_present_usage)

df_lp_prep <- 
  df_lp_kanto %>% 
  recipe(~ .) %>% 
  step_stri_trans(surrounding_present_usage, trans_id = "nfkc") %>% 
  prep(strings_as_factors = FALSE) %>% 
  juice()

df_lp_prep %>% 
  filter(str_detect(surrounding_present_usage, "IC")) %>% 
  pull(surrounding_present_usage)
```



語順を考慮する・しない

考慮しない... 文章の内容を分類
考慮する... n-gram (感情分析)




## Bag-of-Words

* テキスト文書を単語の出現回数のベクトルで表現。
    * 単語がテキストに現れない場合、対応する要素の値は0になる
    * 単語の並び、階層の概念を表現しない。Bag-of-wordsでこれらの意味はない
        * →テキストの意味を正しく理解したい場合にはあまり役立たない
            * →Bag-of-n-Grams
* 全ての単語を同じようにしてカウントすると、必要以上に強調される単語が出る
    * 単純な出現頻度だけでは文書の特徴を表現できない
    * 「意味のある」単語が強調されるような特徴を表現する方法を用いるべき
        * →TF-IDF… TFとIDFの積


トークン化

```{r}

library(tokenizers)
tokenizers::tokenize_words(as.character(d$surrounding_present_usage[1]))

library(textrecipes)
library(recipes)

data(okc_text)

okc_rec <- recipe(~ ., data = okc_text) %>%
  step_tokenize(essay0) %>%
  step_tokenfilter(essay0, min_times = 10) 

okc_obj <- okc_rec %>%
  prep(training = okc_text, retain = TRUE)

juice(okc_obj) %>% 
  slice(2) %>% 
  pull(essay0)


data(okc_text)
okc_text %>% head()

okc_rec <- 
  recipe(~ ., data = okc_text) %>%
  step_tokenize(essay0)

# step_tokenize()
# %>%
#   step_tokenfilter(essay0, max_tokens = 10) %>%
#   step_texthash(essay0)

okc_obj <- 
  okc_rec %>%
  prep(training = okc_text, retain = TRUE)

bake(okc_obj, okc_text) %>% 
  select(starts_with("essay0_hash")) %>% 
  summarise_all(sd) %>% 
  tidyr::gather() %>% 
  arrange(desc(value))
```

<!-- ハッシュ化、ハッシュ関数自体は categorical?? -->


## 単語の除去

Bag-of-Wordsでは、対象の変数に含まれる単語を元に特徴量が生成されますが、中には価値のない単語も含まれます。こうした単語をあらかじめ取り除いておくことは、特徴選択におけるフィルタ方の作業に該当します。

文章の特徴を反映しないような前置詞や冠詞などはその代表です。データ全体で出現頻度の少ない単語も役立つ可能性は低いです。こうした不要な単語が特徴量に含まれないよう、あらかじめ有用でない単語を除去するという方が取られます。

### ストップワードによる単語除去


```{r}
  step_tokenize(surrounding_present_usage) %>% 
  step_stopwords(surrounding_present_usage, custom_stopword_source = "")
```


### 出現頻度による単語のフィルタ

```{r}
library(recipes)
data(covers)

rec <- recipe(~ description, covers) %>%
  step_count(description, pattern = "(rock|stony)", result = "rocks") %>%
  step_count(description, pattern = "famil", normalize = TRUE)

rec2 <- prep(rec, training = covers)
rec2

count_values <- bake(rec2, new_data = covers)
count_values

tidy(rec, number = 1)
tidy(rec2, number = 1)
```


## tf-idf

## 文字列のカウント


```{r}
d <- 
  df_lp_kanto %>% 
  sample_n(10) %>% 
  select(acreage, surrounding_present_usage)

recipe(~ ., data = d) %>%
  step_tokenize(surrounding_present_usage, token = "words") %>% 
  prep(training = d, retain = TRUE) %>% 
  juice() %>% 
  tidyr::unnest(.id = "id") %>% 
  group_by(id, surrounding_present_usage) %>% 
  mutate(n = n()) %>% 
  ungroup() %>% 
  arrange(desc(n))

recipe(~ ., data = d) %>% 
  step_count(surrounding_present_usage, pattern = "(住宅", result = "count_house") %>% 
  prep(d) %>% 
  juice()
```

```{r}
# step_tokenfilter()
```

## ステミング

形態素?



## まとめ

## 関連項目

- 次元削減

## 参考文献

- Benjamin Bengfort, Tony Ojeda, Rebecca Bilbro (2018). Applied Text Analysis with Python Enabling Language-Aware Data Products with Machine Learning (O'Reilly)
- Julia Silge and David Robinson (2017). [Text Mining with R A Tidy Approach](https://www.tidytextmining.com/) (O'Reilly) (**翻訳** 長尾高弘訳 (2018). Rによるテキストマイニング — tidytextを活用したデータ分析と可視化の基礎 (オライリー))
- Alice Zheng and Amanda Casari (2018). Feature Engineering for Machine Learning (O'Reilly) (**翻訳** 株式会社ホクソエム訳 (2019). 機械学習のための特徴量エンジニアリング (オライリー))
