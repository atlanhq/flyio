#' Read shapefiles
#' @description Read shapefiles data from anywhere using a function defined by you
#' @param dsn path of the file to be read
#' @param layer the name of the shapefile without extension
#' @param FUN the function using which the file is to be read
#' @param dsnlayerbind if the FUN needs dsn and layer binded or not
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param ... other parameters for the FUN function defined above
#' @export "rioReadShp"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' rioSetDataSource("gcs")
#' rioSetBucket("socialcops-test")
#' t = rioReadShp("tests/shptest/", "testshp", FUN = readOGR, dsnlayerbind = F)
#' t = rioReadShp("tests/shptest/", "testshp", FUN = shapefile, dsnlayerbind = T)
#' }

rioReadShp <- function(dsn, layer, FUN = rgdal::readOGR, dsnlayerbind = F, data_source = rioGetDataSource(),
                       bucket = rioGetBucket(data_source), ...){
  shpfiles = rioListFiles(path = dsn, pattern = paste0(layer,"."), data_source = data_source, bucket = bucket)
  if(data_source == "local"){
    if(!isTRUE(dsnlayerbind)){
      result = FUN(dsn, layer, ...)
    } else {
      result = FUN(paste0(dsn, "/",layer), ...)
    }
    return(result)
  }
  # downloading the file
  for(i in shpfiles){
    # a tempfile with the required extension
    temp <- paste0(tempdir(), "/", paste0(layer,"."),tools::file_ext(i))
    on.exit(unlink(temp))
    # downloading the file
    downlogical = rioFileDownload(bucketpath = i, localfile = temp,
                                  data_source = data_source, bucket = bucket, overwrite = T)
  }
  # loading the file to the memory using user defined function
  if(!isTRUE(dsnlayerbind)){
    result = FUN(tempdir(), layer, ...)
  } else {
    result = FUN(paste0(tempdir(), "/",layer), ...)
  }
  return(result)
}

