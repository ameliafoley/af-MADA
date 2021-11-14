# Converting coordinates to FIPS

#load  packages
library(readxl) #for loading Excel files
library(dplyr) #for data processing
library(here) #to set paths
library(tidyverse)
library(revgeo) #for reverse geocoding coordinates to zipcode

#import data
popdata <- readRDS(here("popdata_copy.rds"))
#load census API key
tidycensus::census_api_key("c02ef0638e60f9d5fbb45de5219821e3a25cd7d2", install = TRUE, overwrite = TRUE) 

#create function
latlong2fips <- function(latitude, longitude) {
  url <- "https://geo.fcc.gov/api/census/block/find?format=json&latitude=%f&longitude=%f"
  url <- sprintf(url, latitude, longitude)
  json <- RCurl::getURL(url)
  json <- RJSONIO::fromJSON(json)
  as.character(json$Block['FIPS'])
}
#vectorize so function will take more than one argument
latlong2fips_vec <- Vectorize(latlong2fips, vectorize.args = "latitude", "longitude")

fips <- popdata %>% rowwise() %>% mutate(FIPS = latlong2fips_vec(lat, long))
fips <- fips %>% select(-"zip", 
                        -"population")

saveRDS(fips, file = here("fips.RDS"))
