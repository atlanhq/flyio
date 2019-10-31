#' Read RDA file
#' @description Read RData or rda file from anywhere
#' @param file path of the file to be read
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param envir the environment in which to import the objects
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file downloaded
#' @param show_progress logical. Shows progress of the download operation
#' @param ... other parameters for the FUN function defined above
#' @export "import_rda"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' # Load RDA from Google Cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' import_rda("rds-on-cloud.rda", dir = tempdir())
#' }

import_rda <- function(file, FUN = load, data_source = flyio_get_datasource(),
                       bucket = flyio_get_bucket(data_source), envir = globalenv(), dir = flyio_get_dir(), delete_file = TRUE, show_progress = FALSE, ...){

  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("rda", "Rda", "RData"), msg = "Please input a valid path")
  if(data_source == "local"){
    FUN(file, envir = envir, ...)
    return(t)
  }
  # a tempfile with the required extension
  temp <- paste0(dir, "/", basename(file))
  if(isTRUE(delete_file)){on.exit(unlink(temp))}
  # downloading the file
  file = gsub("\\/+","/",file)
  downlogical = import_file(bucketpath = file, localfile = temp, bucket = bucket, show_progress = show_progress)
  assert_that(is.character(downlogical), msg = "Downloading of file failed")
  # loading the file to the memory using user defined function
  FUN(temp, envir = envir, ...)
  return(invisible())
}

