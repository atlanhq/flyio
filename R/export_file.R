#' Upload a file from the local system to cloud
#' @description Write a local file to the cloud, S3 or GCS
#' @param localfile path of the file to be uploaded
#' @param bucketpath path where the file needs to be uploaded, the file name can or cannot be present
#' @param data_source the name of the data source, if not set globally. gcs or s3
#' @param bucket the name of the bucket, if not set globally
#' @param show_progress logical. Shows progress of the upload operation.
#' @param ... other parameters for gcs_upload or aws.s3::put_object
#'
#' @export "export_file"
#' @return the filename and path of the file in the bucket
#' @import "googleCloudStorageR" "aws.s3" "assertthat"
#' @examples
#' \dontrun{
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' export_file("file-local.csv", "file-on-cloud.csv")
#' }

export_file <- function(localfile, bucketpath, data_source = flyio_get_datasource(),
                          bucket = flyio_get_bucket(data_source), show_progress = FALSE, ...){
  # Starting data checks --
  ## valid inputs
  ## valid inputs
  assert_that(is.character(localfile),
              is.character(bucketpath))

  ## data source should be either GCS or S3
  assert_that(str_to_lower(data_source)%in%c("gcs","s3"),
              msg = "Data source should be either GCS or S3")
  data_source = str_to_lower(data_source)

  ## file to upload exists
  assert_that(file.exists(localfile), msg = "Please enter a valid local path to a file")

  ## file extensions for both the paths are same
  if(tools::file_ext(localfile) != tools::file_ext(bucketpath)){
    bucketpath = gsub("\\/+","/",paste0(bucketpath,"/",basename(localfile)))
  }

  ## its not a folder and only a file to upload
  assert_that(!is.dir(localfile),
              msg = "Cannot upload a folder. Make sure its a file.")

  # upload the file if everything is fine
  bucketpath = gsub("\\/+","/",bucketpath)
  if(data_source == "gcs"){
    upload_return = gcs_upload(file = localfile, name = bucketpath, bucket = bucket, ...)
  } else if(data_source == "s3"){
    l <- list(...)
    if(is.null(l$multipart)){
      upload_return = aws.s3::put_object(file = localfile, bucket = bucket, object =  bucketpath, multipart = TRUE, check_region = FALSE, ...)
    } else{
      upload_return = aws.s3::put_object(file = localfile, bucket = bucket, object =  bucketpath, check_region = FALSE, show_progress = show_progress, ...)
    }

  }
  return(invisible(bucketpath))
}

