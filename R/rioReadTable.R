#' Read csv, Excel files, txt
#' @description Read tabular data from anywhere using a function defined by you
#' @param file path of the file to be read
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param ... other parameters for the FUN function defined above
#'
#' @export "rioReadTable"
#' @return the output of the FUN function
#'
#' @examples
#' rioSetDataSource("gcs")
#' rioSetBucket("socialcops-test")
#' rioReadTable("tests/googletest.xlsx", read_excel)
#'

rioReadTable <- function(file, FUN = read.csv, data_source = rioGetDataSource(),
                         bucket = rioGetBucket(data_source), ...){
  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("csv", "xlsx", "xls", "txt"), msg = "Please input a valid path")

  # a tempfile with the required extension
  temp <- tempfile(fileext = paste0(".",tools::file_ext(file)))
  on.exit(unlink(temp))
  # downloading the file
  file = gsub("\\/+","/",file)
  downlogical = rioFileDownload(bucketpath = file, localfile = temp, data_source = data_source, bucket = bucket)
  assert_that(is.character(downlogical), msg = "Downloading of file failed")
  # loading the file to the memory using user defined function
  result = FUN(temp, ...)
  return(result)
}

