## ----setup, include=FALSE--------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ---- include=FALSE--------------------------------------------------------------------------------------
##-------------- 
# **************************************************************************** #
# ***************                Project Overview              *************** #
# **************************************************************************** #
# Author:      Dominick Lemas
# Date:        January 07, 2022
# IRB:         IRB protocol IRB201601899  
#
# version: R version 4.0.3 (2020-10-10)
# version: Rstudio version Version 1.3.1073  

# **************************************************************************** #
# ***************                Objective                     *************** #
# **************************************************************************** #

# (1) compute and format the multiples data.


## ---- message=FALSE--------------------------------------------------------------------------------------
# **************************************************************************** #
# ***************                Library                       *************** #
# **************************************************************************** #
library(tidyverse)
library(dplyr)
library(readxl)
library(fuzzyjoin)



## ---- message=FALSE--------------------------------------------------------------------------------------

# import code variables
n_max=1000000
data.file.name="perinatal_ICD_codes_rawdata_01_2022.xlsx"
data.dir=paste0("~/ehr-preeclampsia-model/documents/datadictionary/")
data_import_directory=paste0(data.dir,data.file.name)


# read data
multiple=read_xlsx(data_import_directory, sheet = "multiples", range = NULL, col_names = TRUE,
          col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf,
          guess_max = min(1000, n_max))


## ---- message=FALSE--------------------------------------------------------------------------------------

# load data
load("~/blue/djlemas/pe_prediction/data/delivery_linked_v0.rda")
load("~/blue/djlemas/pe_prediction/data//mom_perinatal_raw.rda")



## ---- message=FALSE--------------------------------------------------------------------------------------

# PREP ICD CODE 1:N DATA

ehr_codes=df %>%
  filter(perinatal_dx_type=="ENCOUNTER")

# multiples outcomes
# multiple
mult_all=multiple$perinatal_dx_code

# create logic: 1= match %in% outcomes, 0= no match  
ehr_mult = ehr_codes %>%
  mutate(multiple_logic=if_else(perinatal_dx_code %in% mult_all, 1, 0)) 

# Subset to multiple EHR
mult_subset= ehr_mult %>%
  filter(multiple_logic==1) 

# IDs
mom_unique=unique(mult_subset$mom_id)


## ---- message=FALSE--------------------------------------------------------------------------------------

# PREP the DELIVERY 1:1 Data

# rename data
data_final=deliv_final %>%
  rename("mom_id"=mom_id.x) %>%
  select(mom_id,part_dob,gest_start_date) %>%
  mutate(multiple_logic=if_else(mom_id %in% mom_unique, 1, 0)) %>%
  filter(multiple_logic==1) %>%
  group_by(mom_id,part_dob) %>% slice(1)



## ---- message=FALSE--------------------------------------------------------------------------------------

# START LOOP 
chunks=length(unique(mom_unique)) 
pages <- list()

for(i in 1:chunks){
  
  # subset data
  codes_subset=mult_subset %>%
    filter(mom_id==mom_unique[i]) %>%
    select(mom_id,everything())
  
  delivery_subset=data_final %>%
    filter(mom_id==mom_unique[i]) %>%
    select(mom_id,everything())
  
  fuzzy=fuzzy_left_join(codes_subset,delivery_subset,
                        by = c("mom_id" = "mom_id",
                               "perinatal_dx_date" = "part_dob",
                               "perinatal_dx_date"="gest_start_date"),
                        match_fun = list(`==`, `<=`, `>=`)) %>%
    select(-multiple_logic.x,-multiple_logic.y,-mom_id.y)
  pages[[i]] <- fuzzy
} # END LOOP

data_ready=bind_rows(pages)



## ---- message=FALSE--------------------------------------------------------------------------------------

link_final=data_ready

# file name
file_name="multiple_codes_linked_dob_v0.rda"
data_export_directory=paste0("~/blue/djlemas/pe_prediction/data/") 
data_export_path=paste0(data_export_directory,file_name)
deliv_dat %>% save(deliv_dat, file=data_export_path)


