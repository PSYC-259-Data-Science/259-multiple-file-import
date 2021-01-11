#Test import with vroom
library(here)
library(tidyverse)
library(vroom)

rm(list = ls())

here() #Figures out the top-level directory from RProj
here("data_raw") #handy notation for giving us a file or directory path

#If we wanted to read every file name we can use list.files() to get every file that matches a pattern
files <- list.files(here("data_raw"), pattern = "classification200.txt", recursive = T)
#Loads all the filenames into a single tibble.
training <- vroom(here("data_raw",files))

#Write a single, merged file to cleaned data (using here for file path)
training %>% write_csv(here("data_cleaned","training_data.csv"))

#-------------------------

#What if we only wanted participants tagged as include in our participant tracking file?
ppts <- read_csv(here("metadata","ppt_sync.csv")) #Get the master table
id_list <- as.character(ppts$id[ppts$include > 0]) #Pull the included participants
samples <- 200

#Get all the filenames
files <- map_chr(id_list, ~ here("data_raw",.,paste0("classification",samples,".txt"))) #We'll get to this in a few weeks

#Loads all the filenames into a single tibble.
training <- vroom(files)
