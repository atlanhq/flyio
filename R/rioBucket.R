#' Set global bucket name for rIO
#' @description Set global bucket name to be used for all the function in rIO
#' @param bucket the bucket name to be set
#' @param data_source the data source used for IO. Default chooses the data source set using rioSetDataSource()
#'
#' @return stores the bucket name in a global environment under rioBucketGcs or rioBucketS3
#' @export "rioSetBucket"
#' @import "stringr"
#'
#' @examples rioSetBucket(bucket = "socialcops-test", data_source = "S3")
rioSetBucket <- function(bucket, data_source = rioGetDataSource()){
  assert_that(is.string(bucket) && bucket != "", msg = "Enter a valid bucket name")
  assert_that(str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Enter a valid data source")
  data_source = str_to_title(data_source)
  if(data_source == "Gcs"){
    Sys.setenv("rioBucketGcs" = bucket)
  } else if(data_source == "S3"){
    Sys.setenv("rioBucketS3" = bucket)
  } else if(data_source == "Local"){
    Sys.setenv("rioBucketLocal" = bucket)
  }
  message("Default bucket name for ",data_source ," set to '",bucket,"'")
}

#' Get global bucket name for rIO
#' @description Get global bucket name to be used for all the function in rIO
#' @param data_source the data source used for IO. Default chooses the data source set using rioSetDataSource()
#' @return the string - bucket name stored
#' @details if the data source is local, then an empty string is returned
#' @export "rioGetBucket"
#' @import "stringr"
#'
#' @examples rioGetBucket(data_source = "S3")
rioGetBucket <- function(data_source = rioGetDataSource()){
  assert_that(str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Enter a valid data source")
  data_source = str_to_title(data_source)
  if(data_source == "Local") return("")
  bucket = Sys.getenv(paste0("rioBucket",data_source))
  invisible(assert_that(is.string(bucket) && bucket != "", msg = "No bucket set. Use rioSetBucket to set the bucket name globally."))
  return(bucket)
}
