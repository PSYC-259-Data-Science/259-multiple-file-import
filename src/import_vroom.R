#Test import with vroom
library(here)
library(tidyverse)
library(vroom)

rm(list = ls())

here() #Figures out the top-level directory from RProj

ppts <- read_csv(here("metadata","ppt_sync.csv")) #Get the master table
id_list <- as.character(ppts$id[ppts$include > 0]) #Pull the included participants (wrote this in base R for fun)
samples <- 200

#Get all the filenames
files <- map_chr(id_list, ~ here("data_raw",.,paste0("classification",samples,".txt"))) #We'll get to this in a few weeks

#Loads all the filenames into a single tibble. Wow.
training <- vroom(files)

#Write a single, merged file to cleaned data (using here for file path)
training %>% write_csv(here("data_cleaned","training_data.csv"))

