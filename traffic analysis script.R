library(tidyverse)
library(lubridate)
library(viridis)
library(ggmap)

install.packages("ggmap")

install.packages("ggmap", type = "source")

theme_set(theme_bw())

data <- read_csv("data-trafficcounts.csv")

data

colnames(data) <- tolower(colnames(data))
colnames(data) <- gsub(" ", "_", colnames(data))

data <- data %>%
        gather(time, measure, -c(sensor_id, longitude, latitude))

am <- paste0(1:12, "a")
pm <- paste0(1:12, "p")

times <- data_frame(time = c(am, pm),
                    new_time = c(1:24))

data <- data %>% 
        left_join(times) %>% 
        select(-time) %>% 
        rename(time = new_time)

data %>%
        ggplot(aes(time, measure)) + 
                geom_point(alpha = .001) +
                geom_smooth()

data %>% 
        group_by(time) %>% 
        summarize(measure = mean(measure)) %>% 
        ggplot(aes(time, measure)) +
                geom_line()

data %>% 
        group_by(sensor_id) %>% 
        count() %>% 
        arrange(desc(n))

city_map <-  get_map("North Oakland, Pittsburgh, PA", 
                     zoom = 9,
                     maptype = "toner", 
                     source = "stamen")

#View the map to make sure it looks right
ggmap(city_map)

city_map <- ggmap(city_map)

city_map +
        geom_point(data = data, aes(longitude, latitude), alpha = .01)

