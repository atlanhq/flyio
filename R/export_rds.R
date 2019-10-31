#' Write RDS files
#' @description Write R data RDS file to anywhere from R
#' @param x variable name
#' @param file path of the file to be written to
#' @param FUN the function using which the file is to write
#' @param bucket the name of the bucket, if not set globally
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file to be uploaded
#' @param show_progress logical. Shows progress of the upload operation.
#' @param ... other parameters for the FUN function defined above
#'
#' @return if FUN returns anything
#' @export "export_rds"
#' @examples
#' \dontrun{
#' # save RDS on Google Cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' export_rds(iris, "iris-on-cloud.rds", saveRDS, dir = tempdir())
#' }

export_rds <- function(x, file, FUN = saveRDS, data_source = flyio_get_datasource(),
                        bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = TRUE, show_progress = FALSE, ...){
  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("RDS", "rds"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(x, file, ...)
    return(invisible(t))
  }
  # a tempfile with the required extension
  if(isTRUE(delete_file)){
    temp <- tempfile(fileext = paste0(".",tools::file_ext(file)), tmpdir = dir)
    on.exit(unlink(temp))
  } else {
    temp <- paste0(dir, "/", basename(file))
  }
  # loading the file to the memory using user defined function
  file = gsub("\\/+","/",file)
  FUN(x, temp, ...)
  # downloading the file
  export_file(localfile = temp, bucketpath = file, data_source = data_source, bucket = bucket, show_progress = show_progress)

}

