#' Upload a folder from the local system to cloud
#' @description Write a local folder to the cloud, S3 or GCS
#' @param localfolder path of the folder in which all the files are to be uploaded
#' @param pattern pattern of the file names in the folder to be uploaded
#' @param overwrite if files need to be overwritten (if already present)
#' @param bucketpath path of the folder in which the files are to be uploaded
#' @param data_source the name of the data source, if not set globally. can be gcs or s3
#' @param bucket the name of the bucket, if not set globally
#' @param show_progress logical. Shows progress of the upload operation.
#' @param ... other parameters for gcs/s3 upload
#'
#' @export "export_folder"
#' @return the filename and path of the file in the bucket
#' @import "googleCloudStorageR" "aws.s3" "assertthat"
#' @examples
#' \dontrun{
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' export_folder("folder-local/", "folder-on-cloud/")
#' }

export_folder <- function(localfolder, bucketpath, pattern = "*", overwrite = TRUE, data_source = flyio_get_datasource(),
                          bucket = flyio_get_bucket(data_source), show_progress = FALSE, ...){
  # Starting data checks --
  ## valid inputs
  assert_that(is.character(localfolder),
              is.character(bucketpath))

  ## data source should be either GCS or S3
  assert_that(str_to_lower(data_source)%in%c("gcs","s3"),
              msg = "Data source should be either GCS or S3")
  data_source = str_to_lower(data_source)

  ## its not a folder and only a file to upload
  assert_that(tools::file_ext(localfolder) == "" & tools::file_ext(bucketpath) == "",
              msg = "Cannot upload a file. Make sure its a folder")

  ## file to upload exists
  file_upload = list.files(localfolder, pattern = pattern, full.names = T, recursive = T)
  assert_that(length(file_upload)>0, msg = "Please enter a valid local folder with files")

  #removing extra /
  bucketpath = gsub("\\/+","/",bucketpath)

  # if overwrite or not
  if(!isTRUE(overwrite)){
    #removing extra /
    file_upload = gsub("\\/+","/",file_upload)
    localfolder = gsub("\\/+","/",localfolder)

    bucketfiles = list_files(path = bucketpath, pattern = pattern, recursive = T,
                              data_source = data_source, bucket = bucket)
    bucketfiles = gsub(paste0("^",bucketpath), "", bucketfiles, fixed = T)
    bucketfiles = gsub("^\\/+","",bucketfiles)
    localfiles = gsub(paste0("^",localfolder), "", file_upload, fixed = T)
    localfiles = gsub("^\\/+","",localfiles)
    commonfiles = which(localfiles %in% bucketfiles)
    if(length(commonfiles)>0){
      file_upload = file_upload[-commonfiles,]
      assert_that(length(file_upload)>0, msg = "All files already exists")
    }
  }

  # upload the file if everything is fine
  pb <- txtProgressBar(min = 0, max = length(file_upload), style = 3)
  for(i in 1:length(file_upload)){
    bucketpath = gsub("\\/+$","",bucketpath)
    if(data_source == "gcs"){
      upload_return = gcs_upload(file = file_upload[i], name = paste0(bucketpath,"/", basename(file_upload[i])), bucket = bucket, ...)
    } else if(data_source == "s3"){
      upload_return = aws.s3::put_object(file = file_upload[i], bucket = bucket, object =  paste0(bucketpath,"/", basename(file_upload[i])), show_progress = show_progress, ...)
    }
    setTxtProgressBar(pb, i)
  }
  close(pb)
  return(invisible(bucketpath))
}

