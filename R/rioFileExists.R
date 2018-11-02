#' Check if a file exists
#'
#' @param path the entire path for the file
#' @param data_source the name of the data source, gcs, s3 or local; if not set globally
#' @param bucket the name of the bucket, if not set globally
#'
#' @export "rioFileExists"
#' @return logical. if the file exists or not
#'
#' @examples
#' rioSetDataSource("gcs")
#' rioSetBucket("socialcops-test")
#' rioFileExists(path = "tests/mtcars.csv")

rioFileExists <- function(path,  data_source = rioGetDataSource(), bucket = rioGetBucket(data_source)){
  # getting the vector of all the files
  assert_that(is.character(path), is.character(bucket))
  assert_that(str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Enter a valid data source")
  data_source = str_to_lower(data_source)
  if(data_source == "local"){
    return(file.exists(path))
  }
  tryCatch({
    dir_path = dirname(path)
    dir_path = gsub("\\/+","/",dir_path)
    dir_path = gsub("^\\/|^\\.\\/|^\\.","",dir_path)
    obj = rioListFiles(path = dir_path, recursive = T,
                       data_source = data_source, bucket = bucket)
  }, error = function(err){
    print(err)
    return(FALSE)
  })

  # checking if the path lies in the above vector
  path = gsub("\\/+","/",path)
  if(path %in% obj){
    return(TRUE)
  } else{
    return(FALSE)
  }
}
