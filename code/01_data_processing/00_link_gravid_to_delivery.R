


install.packages("tidyverse")
install.packages("fuzzyjoin")

library(tidyverse)
library(fuzzyjoin)

# load data

load("~/blue/djlemas/pe_prediction/data/mom_gravid_raw.rda")
load("~/blue/djlemas/pe_prediction/data/mombaby_delivery_raw.rda")

# format dates

delivery_final = delivery %>%
  mutate_at(vars(gest_start_date, part_dob, delivery_admit_date), as.Date, format = "%Y-%m-%d")

gravid_final = gravid %>%
  mutate_at(vars(pregnancy_start_date), as.Date, format = "%Y-%m-%d")

# join
start_time = Sys.time()

data_ready=fuzzy_left_join(
  delivery_final,gravid_final,
  by = c(
    "mom_id" = "mom_id",
    "gest_start_date" = "pregnancy_start_date",
    "part_dob"="pregnancy_start_date"),
  match_fun = list(`==`, `>=`, `<=`)) 

end_time = Sys.time()
end_time - start_time

delivery=data_ready

# file name
file_name="mombaby_linked_clinical.rda"
data_export_directory=paste0("~/blue/djlemas/pe_prediction/data/") 
data_export_path=paste0(data_export_directory,file_name)
delivery %>% save(delivery, file=data_export_path)
