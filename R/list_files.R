#' List the Files in a Directory/Folder
#' @description list the files in cloud or locally - similar to list.files()
#' @param path the folder for which the files need to be listed
#' @param pattern an optional regular expression. Only file path names that match the regular expression will be returned.
#' @param recursive logical. Should the listing recurse into directories?
#' @param ignore.case logical. Should pattern-matching be case-insensitive?
#' @param full.names logical. Should the entire path be returned or only after the path inputed?
#' @param data_source the name of the data source, gcs, s3 or local; if not set globally
#' @param bucket the name of the bucket, if not set globally
#' @param check_region logical. to check region for aws.s3
#'
#' @export "list_files"
#' @return a vector of full file names
#' @import "googleCloudStorageR" "aws.s3" "stringr"
#' @examples
#' # List files locally
#' list_files(path = tempdir(), data_source = "local")
#' \dontrun{
#' # List files on S3
#' flyio_set_datasource("s3")
#' flyio_set_bucket("your-bucket-name")
#' list_files(path = "tests/", pattern = ".*csv")
#' }

list_files <- function(path = "", pattern = NULL, recursive = FALSE,
                         ignore.case = FALSE, full.names = TRUE,
                         data_source = flyio_get_datasource(), bucket = flyio_get_bucket(data_source), check_region = FALSE){
  assert_that(is.character(path))
  assert_that(str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Input a valid data source")
  data_source = str_to_lower(data_source)

  if(data_source == "local"){
    return(list.files(path = path, pattern = pattern, recursive = recursive, ignore.case = ignore.case,full.names = full.names))
  }

  # getting the vector of all the filenames, with path as prefix
  path = gsub("\\/+","/",path)
  path = gsub("^\\/|^\\.\\/|^\\.","",path)
  if(data_source == "gcs"){
    obj = gcs_list_objects(bucket = bucket, detail = "summary", prefix = path)$name
  } else if(data_source == "s3"){
    obj = unname(unlist(lapply(get_bucket(bucket = bucket, prefix = path, max = Inf,check_region = check_region), `[[`, 1)))
  }

  # if pattern is provided
  if(!is.null(pattern)){
    # look for the pattern in the file paths
    subsetpattern = grep(pattern, obj, ignore.case = ignore.case)
    if(length(subsetpattern)>0){
      obj = obj[subsetpattern]
    } else{
      obj = character(0)
    }
  }
  # if not recursive delete all which are in other folder
  if(!isTRUE(recursive)){
    obj = obj[grep(paste0("^",path,".{1}[A-Za-z0-9_,\\s-]+[.]{1}[A-Za-z]{1+}$"), obj)]
  }
  if(!isTRUE(full.names)){
    obj = sub(paste0("^",path),"",obj)
    obj = gsub("^.*?\\/","", obj)
  }
  return(obj)
}


