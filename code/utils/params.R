
# PARTICIPANT IDS
#----------------

# import variables
n_max=1000000
data_file_name="part_id.csv"
data_dir=paste0("~/ehr-preeclampsia-model/data/raw/part_id/")
data_import_path=paste0(data_dir,data_file_name)

# read data
part_id_list=read_csv(data_import_path, col_types = cols()) %>% 
  dplyr::rename(baby_id = Deidentified_baby_ID, 
                mom_id=Deidentified_mom_ID) %>%
  mutate(baby_id=paste0("baby-",baby_id),
         mom_id=paste0("mom-",mom_id)) 

# mom list
mom_list=unique(part_id_list$mom_id)

# baby list
baby_list=unique(part_id_list$baby_id)

# all list
part_id_list=c(mom_list,baby_list)

rm(data_file_name,n_max,data_dir,data_import_path)

# REDCAP EVENTS
#--------------
event_list=c("2011_arm_1","2012_arm_1","2013_arm_1","2014_arm_1",
             "2015_arm_1","2016_arm_1","2017_arm_1","2018_arm_1",
             "2019_arm_1","2020_arm_1","2021_arm_1","na_arm_1")

# REDCAP INSTRUMENTS
#-------------------
forms=c("demographics","delivery","anthropometrics","diagnosis_codes","labs",
        "vaccines","antibiotics","medications")

# DATA DICTIONARY
#-------------------
# import code variables
data.file.name="perinatal_ICD_codes_rawdata_01_2022.xlsx"
data.dir=paste0("~/ehr-preeclampsia-model/documents/datadictionary/")
data_import_directory=paste0(data.dir,data.file.name)

# multiple-gestation
multgest_codes=read_xlsx(data_import_directory, sheet = "multiples", range = NULL, col_names = TRUE,
                   col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf)

# pe
pe_codes=read_xlsx(data_import_directory, sheet = "pe", range = NULL, col_names = TRUE,
                   col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf)

# hypertension
hyper_codes=read_xlsx(data_import_directory, sheet = "hypertension", range = NULL, col_names = TRUE,
                   col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf)

# diabetes
diab_codes=read_xlsx(data_import_directory, sheet = "diabetes", range = NULL, col_names = TRUE,
                      col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf)

# pulmonary
pulmo_codes=read_xlsx(data_import_directory, sheet = "pulmonary", range = NULL, col_names = TRUE,
                     col_types = NULL, na = "NA", trim_ws = TRUE, skip = 0, n_max = Inf)