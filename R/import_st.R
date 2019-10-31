#' Read geojson, geopkg
#' @description Read geospatial data from anywhere using a function defined by you
#'
#' @param file path of the file to be read
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file downloaded
#' @param show_progress logical. Shows the progress of the download operation
#' @param ... other parameters for the FUN function defined above
#'
#' @export "import_st"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' # for data on cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' data = import_table("excel-file-on-gcs.geojson", dir = tempdir())
#' }

import_st <- function(file, FUN = sf::read_sf, data_source = flyio_get_datasource(),
                         bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = TRUE, show_progress = FALSE, ...){
  # checking if the file is valid
  if(data_source == "local"){
    t = FUN(file, ...)
    return(t)
  }
  # a tempfile with the required extension
  temp <- paste0(dir, "/", basename(file))
  if(isTRUE(delete_file)){on.exit(unlink(temp))}
  # downloading the file
  file = gsub("\\/+","/",file)
  downlogical = import_file(bucketpath = file, localfile = temp, data_source = data_source, bucket = bucket, show_progress = show_progress)
  assert_that(is.character(downlogical), msg = "Downloading of file failed")
  # loading the file to the memory using user defined function
  result = FUN(temp, ...)
  return(result)
}

