#' List buckets for cloud storage
#'
#' @param data_source default to local. Possible options : gcs, s3, local. Case insensitive
#' @param gcs_project Project containing buckets to list in Google Cloud Storage
#'
#' @return vector of bucket names
#' @import "googleCloudStorageR" "aws.s3" "assertthat"
#' @export "list_bucket"
#'
#' @examples
#' # No buckets if data source is local
#' list_bucket(data_source = "local")
#' \dontrun{
#' flyio_set_datasource("s3")
#' flyio_auth() # authentication needed for S3
#' list_bucket()
#' }
list_bucket <- function(data_source = flyio_get_datasource(), gcs_project = ""){

  # checking if data_source input is valid
  invisible(assertthat::assert_that(stringr::str_to_lower(data_source) %in% c("local", "gcs", "s3"),
                                    msg = "data_source should be either local, gcs or s3"))

  # if data source is local return
  if(str_to_lower(data_source) == "local"){
    message("data_source is set to Local. No buckets.")
    return(invisible(""))
  }

  # running authentication for set data source
  if(str_to_lower(data_source) == "gcs"){
    invisible(assertthat::assert_that(gcs_project != "",
                                      msg = "Please specift the project containing buckets to list"))
    buckets = gcs_list_buckets(projectId = gcs_project)
  } else if(str_to_lower(data_source) == "s3"){
    buckets = bucketlist()
  }
  return(buckets)
}
