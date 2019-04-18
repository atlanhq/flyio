#' Write shapefiles
#'
#' @param obj R object to be written
#' @param pathshp the path of the shapefile, which may or may not include the extension
#' @param FUN the function using which the file is to be read
#' @param dsnlayerbind if the FUN needs dsn and layer binded or not
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file to be uploaded
#' @param ... other parameters for the FUN function defined above
#' @export "export_shp"
#' @return output of the FUN function if any
#'
#' @examples
#' \dontrun{
#' # Save shapefile on Google Cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' export_shp(your-shp, "your-shp.shp", driver = "ESRI Shapefile", overwrite = T, dir = tempdir())
#' }


export_shp <- function(obj, pathshp, FUN = rgdal::writeOGR, dsnlayerbind = F, data_source = flyio_get_datasource(),
                        bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = TRUE, ...){
  filename = basename(pathshp)
  layer = gsub(paste0("\\.",tools::file_ext(pathshp),"$"), "", filename)
  dsn = gsub(paste0(filename,"$"),"", pathshp)
  dsnlayer = pathshp
  l <- list(...)
  if(missing(FUN) & is.null(l$driver)){
    FUN1 <- function(...){
      FUN(..., driver = "ESRI Shapefile")
    }
  } else{
    FUN1 = FUN
  }
  if(data_source == "local"){
    if(dsnlayerbind == F){
      result = FUN1(obj, dsn, layer, ...)
    } else{
      result = FUN1(obj, dsnlayer, ...)
    }
    return(invisible(result))
  }
  if(dsnlayerbind == F){
    result = FUN1(obj, tempdir(), layer, ...)
  } else{
    tmplayer = gsub("\\/+","/", paste0(tempdir(),"/",layer,".shp"))
    result = FUN1(obj, tmplayer, ...)
  }
  shpfiles = list.files(path = tempdir(), pattern = paste0(layer,"."))
  shpfiles = grep("dbf|prj|shp|shx|cpg|qpj", shpfiles, value = T)
  # downloading the file
  for(i in shpfiles){
    # a tempfile with the required extension
    temp <- paste0(dir, "/", i)
    if(isTRUE(delete_file)){on.exit(unlink(temp))}
    # uploading the file
    dsnlayer_i = gsub(paste0("\\.",tools::file_ext(dsnlayer),"$"), "", dsnlayer)
    downlogical = export_file(localfile = temp, bucketpath = paste0(dsnlayer_i, ".", tools::file_ext(i)),
                                bucket = bucket, data_source = data_source)
  }
}

