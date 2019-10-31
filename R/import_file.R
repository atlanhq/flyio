
#' Download file from cloud to local system
#' @description Save a single file from the cloud to your local drive
#' @param bucketpath path of file in the bucket
#' @param localfile path where the file needs to be downloaded. The file name and extension also need to be present; if not, the current file name will be considered
#' @param data_source the name of the data source, if not set globally, gcs or s3
#' @param bucket the name of the bucket, if not set globally
#' @param overwrite logical. If the files should be overwritten if already present
#' @param show_progress logical. Shows progress of the download operation
#' @param ... other parameters for gcs_get_object or save_object
#'
#' @return the filename and path of the object saved to local
#' @export "import_file"
#' @import "googleCloudStorageR" "aws.s3" "stringr" "assertthat"
#' @examples
#' \dontrun{
#' # import data from GCS to Local
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' import_file("mtcars.csv", paste0(tempdir(), "/mtcars.csv"), overwrite = T)
#' }

import_file <- function(bucketpath, localfile, data_source = flyio_get_datasource(),
                            bucket = flyio_get_bucket(data_source),  overwrite = TRUE, show_progress = FALSE, ...){
  # Starting data checks --
  ## valid inputs
  assert_that(is.character(localfile),
              is.character(bucketpath))

  ## data source should be either GCS or S3
  assert_that(str_to_lower(data_source)%in%c("gcs","s3"),
              msg = "Data source should be either GCS or S3")
  data_source = str_to_lower(data_source)

  ## file to upload exists
  assert_that(file_exists(bucketpath, bucket = bucket, data_source = data_source),
              msg = "Please enter a valid bucket path to a file")

  ## file extensions for both the paths are same
  if(tools::file_ext(localfile) != tools::file_ext(bucketpath)){
    is.dir(localfile)
    localfile = gsub("\\/+","/",paste0(localfile,"/",basename(bucketpath)))
  }

  ## its not a folder and only a file to upload
  assert_that(tools::file_ext(localfile) != "" & tools::file_ext(bucketpath) != "",
    msg = "Cannot upload a folder. Make sure its a file.")

  # upload the file if everything is fine
  bucketpath = gsub("\\/+","/",bucketpath)
  if(data_source == "gcs"){
    save_file = gcs_get_object(object_name = bucketpath,bucket = bucket, saveToDisk = localfile, overwrite = overwrite, ...)
  } else if(data_source == "s3"){
    save_file = aws.s3::save_object(object = bucketpath, bucket = bucket, file = localfile, overwrite = overwrite, check_region = FALSE, show_progress = show_progress, ...)
  }
  return(invisible(localfile))
}
