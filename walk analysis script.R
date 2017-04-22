library(tidyverse)
library(lubridate)
library(viridis)
library(ggmap)


theme_set(theme_bw())

data <- read_csv("walkscorect.xls---walk-score-by-ct.csv")

data

colnames(data) <- tolower(colnames(data))
colnames(data) <- gsub(" ", "_", colnames(data))

