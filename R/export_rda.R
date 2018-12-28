#' Write RDA files
#' @description Write R data RDA file to anywhere from R
#' @param ... R ojects need to be saved
#' @param file path of the file to be written to
#' @param FUN the function using which the file is to write
#' @param bucket the name of the bucket, if not set globally
#' @param data_source the name of the data source, if not set globally. s3, gcs or local

#'
#' @return No output
#' @export "export_rda"
#' @examples
#' \dontrun{
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("socialcops-test")
#' export_rda(iris, mtcars, "tests/iris.rda")
#' }

export_rda <- function(..., file, FUN = save, data_source = flyio_get_datasource(),
                        bucket = flyio_get_bucket(data_source)){
  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("rda", "Rda","RData"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(..., file = file)
    return(invisible(t))
  }
  # a tempfile with the required extension
  temp <- tempfile(fileext = paste0(".",tools::file_ext(file)))
  on.exit(unlink(temp))
  # loading the file to the memory using user defined function
  file = gsub("\\/+","/",file)
  FUN(..., file = temp)
  # uploading the file
  export_file(localfile = temp, bucketpath = file, data_source = data_source, bucket = bucket)

}

