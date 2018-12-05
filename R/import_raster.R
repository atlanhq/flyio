#' Read raster files
#'
#' @description Read raster data from anywhere using a function defined by you
#' @param file path of the file to be read
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param ... other parameters for the FUN function defined above
#'
#' @export "import_raster"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("socialcops-test")
#' t = import_raster("tests/testras.tif", raster)
#' }

import_raster <- function(file, FUN = raster::raster, data_source = flyio_get_datasource(),
                          bucket = flyio_get_bucket(data_source), ...){

  # checking if the file is valid
  assert_that(tools::file_ext(file) %in% c("tif", "hdf"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(file, ...)
    return(t)
  }
  # a tempfile with the required extension
  temp <- tempfile(fileext = paste0(".",tools::file_ext(file)))
  #  on.exit(unlink(temp))
  # downloading the file
  file = gsub("\\/+","/",file)
  downlogical = import_file(bucketpath = file, localfile = temp, bucket = bucket)
  assert_that(is.character(downlogical), msg = "Downloading of file failed")
  # loading the file to the memory using user defined function
  result = FUN(temp, ...)
  return(result)
}

