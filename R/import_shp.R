#' Read shapefiles
#' @description Read shapefiles data from anywhere using a function defined by you
#' @param pathshp path of the shp file to be read
#' @param FUN the function using which the file is to be read
#' @param dsnlayerbind if the FUN needs dsn and layer binded or not
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file downloaded
#' @param ... other parameters for the FUN function defined above
#' @export "import_shp"
#' @return the output of the FUN function
#'
#' @examples
#' \dontrun{
#' # import shapefile from Google Cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' t = import_shp("shptest-on-cloud.shp", FUN = readOGR, dsnlayerbind = F, dir = tempdir())
#' t = import_shp("shptest-on-cloud.shp", FUN = raster::shapefile, dsnlayerbind = T, dir = tempdir())
#' }

import_shp <- function(pathshp, FUN = rgdal::readOGR, dsnlayerbind = F, data_source = flyio_get_datasource(),
                       bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = TRUE, ...){
  filename = basename(pathshp)
  layer = gsub(paste0("\\.",tools::file_ext(pathshp),"$"), "", filename)
  dsn = gsub(paste0(filename,"$"),"", pathshp)
  dsnlayer = pathshp
  shpfiles = list_files(path = dsn, pattern = paste0(layer,"."), data_source = data_source, bucket = bucket)
  shpfiles = grep("dbf|prj|shp|shx|cpg|qpj", shpfiles, value = T)
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
    temp <- paste0(dir, "/", paste0(layer,"."),tools::file_ext(i))
    if(isTRUE(delete_file)){on.exit(unlink(temp))}
    # downloading the file
    downlogical = import_file(bucketpath = i, localfile = temp,
                                  data_source = data_source, bucket = bucket, overwrite = T)
  }
  # loading the file to the memory using user defined function
  if(!isTRUE(dsnlayerbind)){
    result = FUN(dir, layer, ...)
  } else {
    result = FUN(paste0(dir, "/",layer), ...)
  }
  return(result)
}

