install.packages("tidyverse")
install.packages("fuzzyjoin")

library(tidyverse)
library(fuzzyjoin)

# LOAD

load("~/blue/djlemas/pe_prediction/data/mom_gravid_raw.rda")
load("~/blue/djlemas/pe_prediction/data/mombaby_delivery_raw.rda")

# FORMAT

delivery_final = delivery %>%
  mutate_at(vars(gest_start_date, part_dob, delivery_admit_date), as.Date, format = "%Y-%m-%d") %>% ungroup() %>% select(-part_id)

delivery_ids=unique(delivery_final$mom_id)

gravid_final = gravid %>%
  mutate_at(vars(pregnancy_start_date), as.Date, format = "%Y-%m-%d") %>% 
  ungroup() %>% select(-part_id) %>% drop_na()


# START LOOP 
chunks=length(unique(delivery_ids)) 
pages <- list()

for(i in 1:chunks){
  
  # subset data
  delivery_subset=delivery_final %>%
    filter(mom_id==delivery_ids[i]) %>%
    select(mom_id,everything())
  
  gravid_subset=gravid_final %>%
    filter(mom_id==delivery_ids[i]) %>%
    select(mom_id,everything())
  
  fuzzy=fuzzy_left_join(delivery_subset,gravid_subset,
                        by = c("mom_id" = "mom_id",
                               "part_dob" = "pregnancy_start_date",
                               "gest_start_date"="pregnancy_start_date"),
                        match_fun = list(`==`, `>=`, `<=`)) 
  pages[[i]] <- fuzzy
} # END LOOP

data_ready=bind_rows(pages)

deliv_dat=data_ready

# file name
file_name="mombaby_linked_clinical.rda"
data_export_directory=paste0("~/blue/djlemas/pe_prediction/data/") 
data_export_path=paste0(data_export_directory,file_name)
deliv_dat %>% save(deliv_dat, file=data_export_path)