#' Check if a file exists
#'
#' @param path the entire path for the file
#' @param data_source the name of the data source, if not set globally. s3, gsc or local
#' @param bucket the name of the bucket, if not set globally
#'
#' @export "file_exists"
#' @return logical. if the file exists or not
#'
#' @examples
#' # Check with data source local
#' file_exists(path = "tests/mtcars.csv", data_source = "local")
#' \dontrun{
#' # Check with data source GCS
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' file_exists(path = "tests/mtcars.csv")
#' }

file_exists <- function(path,  data_source = flyio_get_datasource(), bucket = flyio_get_bucket(data_source)){
  # getting the vector of all the files
  assert_that(is.character(path), is.character(bucket))
  assert_that(str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Enter a valid data source")
  data_source = str_to_lower(data_source)
  if(data_source == "local"){
    return(file.exists(path))
  }
  tryCatch({
    # dir_path = dirname(path)
    # dir_path = gsub("\\/+","/",dir_path)
    # dir_path = gsub("^\\/|^\\.\\/|^\\.","",dir_path)
    obj = list_files(path = path, recursive = T,
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
