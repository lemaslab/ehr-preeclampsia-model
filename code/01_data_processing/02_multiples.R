install.packages("tidyverse")
install.packages("fuzzyjoin")
install.packages("readxl")


library(tidyverse)
library(readxl)
library(fuzzyjoin)


# import code variables
data.file.name="perinatal_ICD_codes_rawdata_01_2022.xlsx"
data.dir=paste0("~/blue/djlemas/pe_prediction/data/")
data_import_directory=paste0(data.dir,data.file.name)

# read data
multiple=read_xlsx(data_import_directory, sheet = "multiples", range = NULL, col_names = TRUE,
          col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf)


# load data
load("~/blue/djlemas/pe_prediction/data/delivery_linked_v0.rda")
load("~/blue/djlemas/pe_prediction/data//mom_perinatal_raw.rda")


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


# PREP the DELIVERY 1:1 Data

# rename data
data_final=deliv_final %>%
  rename("mom_id"=mom_id.x) %>%
  select(mom_id,part_dob,gest_start_date,baby_gest_age_raw, weeks,days) %>%
  mutate(multiple_logic=if_else(mom_id %in% mom_unique, 1, 0)) %>%
  filter(multiple_logic==1) %>%
  group_by(mom_id,part_dob) %>% slice(1)

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

data_ready=bind_rows(pages) %>%
  rename("mom_id"="mom_id.x")

multgest_dx_dob_v1=data_ready

# file name
file_name="multiple_codes_dob_v1.rda"
data_export_directory=paste0("~/blue/djlemas/pe_prediction/data/") 
data_export_path=paste0(data_export_directory,file_name)
multgest_dx_dob_v1 %>% save(multgest_dx_dob_v1, file=data_export_path)


