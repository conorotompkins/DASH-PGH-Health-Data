library(tidyverse)
library(lubridate)
library(viridis)

theme_set(theme_bw())

data <- read_csv("fastfoodalleghenycounty.csv")

summary(data)
data

colnames(data) <- tolower(colnames(data))
colnames(data) <- gsub(" ", "_", colnames(data))

data <- data %>% 
        rename(street_number = `street_#`) %>% 
        mutate(start_date = mdy(start_date),
               zip = as.character(zip))

data %>% 
        group_by(zip) %>% 
        count() %>% 
        arrange(desc(n))

data %>% 
        arrange(start_date, legal_name) %>% 
        group_by(legal_name, start_date) %>% 
        count() %>% 
        mutate(cumulative = cumsum(n)) %>% 
        ggplot(aes(start_date, cumulative, color = legal_name)) +
                geom_line(show.legend = FALSE)

#Data is only for stores that were open in a certain period in 2016. Not historical
