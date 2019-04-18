#' Write raster
#' @param x variable name
#' @param file path of the file to be written to
#' @param FUN the function using which the file is to write
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file to be uploaded
#' @param ... other parameters for the FUN function defined above
#' @export "export_raster"
#' @return No output
#'
#' @examples
#' \dontrun{
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' r1 <- raster(nrows=108, ncols=21, xmn=0, xmx=10)
#' export_raster(r1, "raster-cloud.tif", writeRaster, format = "GTiff", dir = tempdir())
#' }

export_raster <- function(x, file, FUN = raster::writeRaster, data_source = flyio_get_datasource(),
                           bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = TRUE, ...){
  # checking if the file is valid
  #assert_that(tools::file_ext(file) %in% c("tif", "hdf"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(x, file, ...)
    return(invisible(t))
  }
  # a tempfile with the required extension
  if(isTRUE(delete_file)){
    temp <- tempfile(fileext = paste0(".",tools::file_ext(file)), tmpdir = dir)
    on.exit(unlink(temp))
  } else {
    temp <- paste0(dir, "/", basename(file))
  }

  # loading the file to the memory using user defined function
  file = gsub("\\/+","/",file)
  FUN(x, temp, ...)
  # downloading the file
  export_file(localfile = temp, bucketpath = file, data_source = data_source, bucket = bucket)
}

