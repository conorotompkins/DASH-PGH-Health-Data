library(lubridate)
library(viridis)
library(ggmap)
library(rgdal)
library(sp)
library(raster)
library(tidyverse)

theme_set(theme_bw())

df <- read_csv("data-trafficcounts.csv")

df

colnames(df) <- tolower(colnames(df))
colnames(df) <- gsub(" ", "_", colnames(df))

df <- df %>%
        gather(time, measure, -c(sensor_id, longitude, latitude))

am <- paste0(1:12, "a")
pm <- paste0(1:12, "p")

times <- data_frame(time = c(am, pm),
                    new_time = c(1:24))

df <- df %>% 
        left_join(times) %>% 
        select(-time) %>% 
        rename(time = new_time)

df %>%
        ggplot(aes(time, measure)) + 
                geom_point(alpha = .001) +
                geom_smooth()

df %>% 
        group_by(time) %>% 
        summarize(measure = mean(measure)) %>% 
        ggplot(aes(time, measure)) +
                geom_line()

df %>% 
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
        geom_point(data = df, aes(longitude, latitude), alpha = .01)


#Load census tract data
#Note: function `shapefile` is a neater than `readOGR()`
#Note: The usage of `@` to access attribute data tables associated with spatial objects in R
tract <- shapefile("pa_census_track/cb_2016_42_tract_500k.shp")
tract <- spTransform(x=tract, CRSobj=CRS("+proj=longlat +datum=WGS84"))
names(tract@data) <- tolower(names(tract@data))

#Convert crime data to a spatial points object
df_sf <- SpatialPointsDataFrame(coords=df[, c("longitude", "latitude")],
                             data=df[, c("sensor_id", "measure", "time")],
                             proj4string=CRS("+proj=longlat +datum=WGS84"))


#Spatial overlay to identify census polygon in which each crime point falls
#The Result `vc_tract` is a dataframe with the tract data for each point
df_tract <- over(x=df_sf, y=tract)

#Add tract data to crimePoints
df_sf@data <- data.frame(df_sf@data, df_tract)

df_sf@coords$longitude
