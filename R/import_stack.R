#' Read stack from GCS/S3 or local
#' @description Read Stack/Brick data from anywhere using a function defined by you
#' @param pathstack vector of paths of rasters (layers)
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file downloaded
#' @param ... other parameters for the FUN function defined above
#' @export "import_stack"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' # Import stack from Google Cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' t = import_stack("tests/raster-cloud/", dir = tempdir())
#' }

import_stack <- function(pathstack, FUN = raster::stack, data_source = flyio_get_datasource(),
                       bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = FALSE, ...){


  if(data_source == "local"){
    result = FUN(pathstack, ...)
    return(result)
  }
  # downloading the file
  for(i in pathstack){
    # a tempfile with the required extension
    temp <- paste0(dir, "/", basename(i))
    if(isTRUE(delete_file)){on.exit(unlink(temp))}
    # downloading the file
    downlogical = import_file(bucketpath = i, localfile = temp,
                              data_source = data_source, bucket = bucket, overwrite = T)
  }
  # loading the file to the memory using user defined function
  result = FUN(paste0(dir, "/",basename(pathstack)), ...)
  return(result)
}

