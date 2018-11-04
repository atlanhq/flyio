#' Write csv, Excel files, txt
#'
#' @param x variable name
#' @param file path of the file to be written to
#' @param FUN the function using which the file is to write
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param ... other parameters for the FUN function defined above

#'
#' @return No output
#' @export "rioWriteTable"
#' @examples
#' \dontrun{
#' rioSetDataSource("gcs")
#' rioSetBucket("socialcops-test")
#' rioWriteTable(iris, "tests/iris.csv", write.csv)
#' }

rioWriteTable <- function(x, file, FUN = write.csv, data_source = rioGetDataSource(),
                          bucket = rioGetBucket(data_source), ...){

  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("csv", "xlsx", "xls", "txt"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(x, file, ...)
    return(invisible(t))
  }
  # a tempfile with the required extension
  temp <- tempfile(fileext = paste0(".",tools::file_ext(file)))
  on.exit(unlink(temp))

  # loading the file to the memory using user defined function
  file = gsub("\\/+","/",file)
  FUN(x, temp, ...)
  # downloading the file
  rioFileUpload(localfile = temp, bucketpath = file, data_source = data_source, bucket = bucket)

}

