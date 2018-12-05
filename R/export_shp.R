#' Write shapefiles
#'
#' @param obj R object to be written
#' @param pathshp the path of the shapefile, may or may not include the extension
#' @param FUN the function using which the file is to be read
#' @param dsnlayerbind if the FUN needs dsn and layer binded or not
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param ... other parameters for the FUN function defined above
#' @export "export_shp"
#' @importFrom rgdal writeOGR
#' @return output of the FUN function if any
#'
#' @examples
#' \dontrun{
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("socialcops-test")
#' export_shp(t, "tests/shptest/", "new", driver = "ESRI Shapefile", overwrite = T)
#' }


export_shp <- function(obj, pathshp, FUN = rgdal::writeOGR, dsnlayerbind = F, data_source = flyio_get_datasource(),
                        bucket = flyio_get_bucket(data_source), ...){
  filename = basename(pathshp)
  layer = gsub(paste0("\\.",tools::file_ext(pathshp),"$"), "", filename)
  dsn = gsub(paste0(filename,"$"),"", pathshp)
  dsnlayer = gsub("\\/+","/", paste0(dsn,"/",layer))
  l <- list(...)
  if(identical(FUN, rgdal::writeOGR) & is.null(l$driver)){
    FUN <- function(...){
      rgdal::writeOGR(..., driver = "ESRI Shapefile")
    }
  }
  if(data_source == "local"){
    if(dsnlayerbind == F){
      result = FUN(obj, dsn, layer, ...)
    } else{
      result = FUN(obj, dsnlayer, ...)
    }
    return(invisible(result))
  }
  if(dsnlayerbind == F){
    result = FUN(obj, tempdir(), layer, ...)
  } else{
    tmplayer = gsub("\\/+","/", paste0(tempdir(),"/",layer))
    result = FUN(obj, tmplayer, ...)
  }
  shpfiles = list.files(path = tempdir(), pattern = paste0(layer,"."))
  shpfiles = grep("dbf|prj|shp|shx|cpg|qpj", shpfiles, value = T)
  # downloading the file
  for(i in shpfiles){
    # a tempfile with the required extension
    temp <- paste0(tempdir(), "/", i)
    on.exit(unlink(temp))
    # downloading the file
    downlogical = export_file(localfile = temp, bucketpath = paste0(dsnlayer, ".", tools::file_ext(i)),
                                bucket = bucket)
  }
}

