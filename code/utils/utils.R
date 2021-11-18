#' Get RedCap API Token
#' @return api token
get_API_token <- function(credential_label){
  # Get Emoncms API Token
  credential_path <- paste(Sys.getenv("USERPROFILE"), '\\DPAPI\\passwords\\', Sys.info()["nodename"], '\\', credential_label, '.txt', sep="")
  token<-decrypt_dpapi_pw(credential_path)
  return(token)
}

#' Outersect Function
#' Description: To find the non-duplicated elements between two or more vector

outersect <- function(x, y) {
  sort(c(setdiff(x, y),
         setdiff(y, x)))
} # END FUNCTION



#' Get RedCap Data
#' Description: Return tibble with ehr data.
#' @return tibble containing: part_id + "variable-of-interest"
getData_redcap <- function(api_token,uri,records,variables,col_types){
  
  # parameters to troubleshoot
  # records=mom_list[1:1500]
  # event_list=c("2011_arm_1")
  # uri='https://redcap.ctsi.ufl.edu/redcap/api/'
  # api_token
  
  # create part_id batch
  batchSize=100
  chunks=split(records, floor(1:(length(records))/batchSize))
  
  # START LOOP  
  pages <- list()
  
  for(i in 1:length(chunks)){
    redcap_data=redcap_read(batch_size=200, 
                            redcap_uri=uri, 
                            token=api_token,
                            records=chunks[[i]],
                            fields=variables,
                            col_types=col_types)$data
    pages[[i]] <- redcap_data
  } # END LOOP
  redcap_final=bind_rows(pages)
  return(redcap_final)
} # end function


