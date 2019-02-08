#' Read stack
#' @description Read Stack/Brick data from anywhere using a function defined by you
#' @param pathstack vector of paths of rasters (layers)
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param ... other parameters for the FUN function defined above
#' @export "import_shp"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("socialcops-test")
#' t = import_shp("tests/shptest/")
#' }

import_stack <- function(pathstack, FUN = raster::stack, data_source = flyio_get_datasource(),
                       bucket = flyio_get_bucket(data_source), ...){


  if(data_source == "local"){
    result = FUN(pathstack, ...)
    return(result)
  }
  # downloading the file
  for(i in pathstack){
    # a tempfile with the required extension
    temp <- paste0(tempdir(), "/", basename(i))
    # downloading the file
    downlogical = import_file(bucketpath = i, localfile = temp,
                              data_source = data_source, bucket = bucket, overwrite = T)
  }
  # loading the file to the memory using user defined function
  result = FUN(paste0(tempdir(), "/",basename(pathstack)), ...)
  return(result)
}

