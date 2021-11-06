#' Get RedCap API Token
#' @return api token
get_API_token <- function(credential_label){
  # Get Emoncms API Token
  credential_path <- paste(Sys.getenv("USERPROFILE"), '\\DPAPI\\passwords\\', Sys.info()["nodename"], '\\', credential_label, '.txt', sep="")
  token<-decrypt_dpapi_pw(credential_path)
  return(token)
}

