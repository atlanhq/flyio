#' Read RDS file
#' @description Read R data - RDS file from anywhere
#' @param file path of the file to be read
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param ... other parameters for the FUN function defined above
#' @export "rioReadRds"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' rioSetDataSource("gcs")
#' rioSetBucket("socialcops-test")
#' rioReadRds("tests/googletest.rds", readRDS)
#' }

rioReadRds <- function(file, FUN = readRDS, data_source = rioGetDataSource(),
                       bucket = rioGetBucket(data_source), ...){

  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("RDS", "rds"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(file, ...)
    return(t)
  }
  # a tempfile with the required extension
  temp <- tempfile(fileext = paste0(".",tools::file_ext(file)))
  on.exit(unlink(temp))
  # downloading the file
  file = gsub("\\/+","/",file)
  downlogical = rioFileDownload(bucketpath = file, localfile = temp, bucket = bucket)
  assert_that(is.character(downlogical), msg = "Downloading of file failed")
  # loading the file to the memory using user defined function
  result = FUN(temp, ...)
  return(result)
}

