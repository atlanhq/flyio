#' Write RDA files
#' @description Write R data RDA file to anywhere from R
#' @param ... R pbjects need to be saved
#' @param file path of the file to be written to
#' @param FUN the function using which the file is to write
#' @param bucket the name of the bucket, if not set globally
#' @param data_source the name of the data source, if not set globally. s3, gcs or local

#'
#' @return No output
#' @export "rioWriteRda"
#' @examples
#' \dontrun{
#' rioSetDataSource("gcs")
#' rioSetBucket("socialcops-test")
#' rioWriteRda(iris, mtcars, "tests/iris.rda")
#' }

rioWriteRda <- function(..., file, FUN = save, data_source = rioGetDataSource(),
                        bucket = rioGetBucket(data_source)){
  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("rda", "Rda"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(..., file)
    return(invisible(t))
  }
  # a tempfile with the required extension
  temp <- tempfile(fileext = paste0(".",tools::file_ext(file)))
  on.exit(unlink(temp))
  # loading the file to the memory using user defined function
  file = gsub("\\/+","/",file)
  FUN(..., file = temp)
  # downloading the file
  rioFileUpload(localfile = temp, bucketpath = file, data_source = data_source, bucket = bucket)

}

