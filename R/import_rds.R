#' Read RDS file
#' @description Read R data - RDS file from anywhere
#' @param file path of the file to be read
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file downloaded
#' @param show_progress logical. Shows progress of the download operation
#' @param ... other parameters for the FUN function defined above
#' @export "import_rds"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' # Import RDS from Google Cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' import_rds("rds-on-cloud.rds", readRDS, dir = tempdir())
#' }

import_rds <- function(file, FUN = readRDS, data_source = flyio_get_datasource(),
                       bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = TRUE, show_progress = FALSE, ...){

  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("RDS", "rds"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(file, ...)
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
  result = FUN(temp, ...)
  return(result)
}

