FROM rocker/geospatial:3.6.0@sha256:2e57034b1b855a68e9089372d8e0b46d16eec925f80fdad246ea1e646f12857d

RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    fonts-ipaexfont \
    gnupg \
    mecab \
    libmecab-dev \
    mecab-ipadic-utf8 && \
  curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
  apt-get install -y --no-install-recommends \
    nodejs && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  npm install npm@latest -g && \
  rm -rf /tmp/npm-*

ARG GITHUB_PAT

RUN set -x && \
  echo "GITHUB_PAT=$GITHUB_PAT" >> /usr/local/lib/R/etc/Renviron

RUN set -x && \
  install2.r --error \
    assertr \
    Boruta \
    car \
    caret \
    cattonum \
    conflicted \
    corrr \
    cowplot \
    DALEX \
    data.table \
    DMwR \
    drake \
    embed \
    ensurer \
    GGally \
    here \ 
    janitor \
    jpndistrict \
    kokudosuuchi \
    lwgeom \
    mapview \
    mlr \
    mice \
    naniar \
    recipes \
    rnaturalearth \
    skimr \
    StanHeaders \
    textrecipes \
    tidymodels \
    usethis \
    visdat && \
  installGithub.r \
    "r-lib/rlang" \
    "ropenscilabs/rnaturalearthhires" \
    "tidyverse/dtplyr" \
    "tidyverse/tidyr" \
    "uribo/jpmesh" \
    "uribo/textlintr" && \
  Rscript -e \
    'install.packages("RMeCab", repos = "http://rmecab.jp/R")' && \
  Rscript -e \
    'remotes::install_git("https://gitlab.com/uribo/jmastats")' && \
  rm -rf /tmp/downloaded_packages/ /tmp/*.rds
