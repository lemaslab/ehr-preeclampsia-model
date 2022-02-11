install.packages("tidyverse")
install.packages("fuzzyjoin")
install.packages("readxl")


library(tidyverse)
library(readxl)
library(fuzzyjoin)


# hypertension_codes: import icd-code information (1:1 structure)
data.file.name="perinatal_ICD_codes_rawdata_01_2022.xlsx"
data.dir=paste0("~/")
data_import_directory=paste0(data.dir,data.file.name)
hyper_codes=read_xlsx(data_import_directory, sheet = "hypertension", range = NULL, col_names = TRUE,
                   col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf)

# df: import perinatal icd-code EHR data (1:n structure)
load("~/mom_perinatal_raw.rda")

# delivery_final_v1: import linked delivery data (1:1 structure)
load("~/delivery_linked_v4.rda")

# PREP ICD CODE 1:N DATA


df=df%>%
  rename("mom_id" = Deidentified_mom_ID,
         "perinatal_dx_date" = `Diagnosis Start Date`,
         "perinatal_dx_code" = `Diagnosis Code`,
         "perinatal_dx_descrip" = `Diagnosis Description`,
         "perinatal_dx_type" = `Diagnosis Type`)


# ICD codes
icd_codes=hyper_codes %>%
  filter(perinatal_dx_category=="hypertension") %>% pull(perinatal_dx_code)

# EHR data
ehr_codes=df %>%
  filter(perinatal_dx_type=="ENCOUNTER") %>%
  mutate(ehr_logic=if_else(perinatal_dx_code %in% icd_codes, 1, 0)) %>%
  filter(ehr_logic==1) %>%
  select(-ehr_logic)

ehr_codes$mom_id<-paste("mom-", ehr_codes$mom_id, sep = "")

# IDs
mom_unique=unique(ehr_codes$mom_id)


# PREP the DELIVERY 1:1 Data

data_final=delivery_final_v4 %>%
  select(mom_id,part_dob,gest_start_date,baby_gest_age_raw,weeks,days) %>%
  mutate(ehr_logic=if_else(mom_id %in% mom_unique, 1, 0)) %>%
  filter(ehr_logic==1) %>%
  group_by(mom_id,part_dob) %>% slice(1) %>%
  select(-ehr_logic)


# START LOOP (RUN on UFRC)
chunks=length(unique(mom_unique)) 
pages <- list()

for(i in 1:chunks){
  
  # subset data
  codes_subset=ehr_codes %>%
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
    select(-mom_id.y)
  pages[[i]] <- fuzzy
} # END LOOP

data_ready=bind_rows(pages) %>%
  rename("mom_id"="mom_id.x")

hyper_dx_dob_v0=data_ready

# file name
file_name="hyper_codes_dob_v0.rda"
data_export_directory=paste0("~/") 
data_export_path=paste0(data_export_directory,file_name)
hyper_dx_dob_v0 %>% save(hyper_dx_dob_v0, file=data_export_path)

