library(tidyverse)

rm(list = ls())

here() #Figures out the top-level directory from RProj

#Get the master table -- what can we do with it?
ppts <- read_csv(here("metadata","ppt_sync.csv")) 

id_list <- as.character(ppts$id[ppts$include > 0]) #Pull the included participants (wrote this in base R for fun)
#id_list <- ppts %>% filter(include > 0) %>% pull(id) %>% as.character() #If you wanted it as tidy
samples <- 200

first_set <- TRUE #Why do we need this?

#READ_CSV WITH BIND_ROWS
for (id in id_list) {
  file_name <- here("data_raw",id,paste0("classification",samples,".txt"))
  temp_ds <- read_csv(file_name)
  
  if (first_set) {
    training <- temp_ds #On the first loop, the temp data becomes the data set
    first_set <- FALSE
  } else {
    training <- bind_rows(training, temp_ds) #On subsequent loops, bind rows to the bottom
  }
}

#Write to cleaned data
training %>% write_csv(here("data_cleaned","training_data.csv"))
