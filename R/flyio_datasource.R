#' Set global data source name for flyio
#' @description Set global data source name to be used for all the function in flyio
#' @param data_source the DataSource name to be set
#'
#' @return stores the data source name in a global environment under flyioDataSource
#' @export "flyio_set_datasource"
#' @import "stringr"
#' @examples flyio_set_datasource("local")
flyio_set_datasource <- function(data_source){
  invisible(assert_that(is.string(data_source) && str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Enter a valid data source name"))
  data_source = str_to_lower(data_source)
  Sys.setenv("CLOUD_STORAGE_NAME" = data_source)
  message("Default Data Source name set to '",data_source,"'")
}

#' Get global data source name for flyio
#' @description Get global data source name to be used for all the functions in flyio. Returns the value stored using flyio_set_datasource
#' @return the string - data source name stored
#' @export "flyio_get_datasource"
#'
#' @examples
#' # first setting the data source
#' flyio_set_datasource("s3")
#' # getting the data source
#' flyio_get_datasource()
flyio_get_datasource <- function(){
  data_source = Sys.getenv("CLOUD_STORAGE_NAME")
  if(data_source == ""){
    data_source = Sys.getenv("flyioDataSource")
    if(data_source != ""){
      message("flyioDataSource env name is depreciated. Please use CLOUD_STORAGE_NAME.")
    }
  }
  invisible(assert_that(is.string(data_source) && data_source != "", msg = "No data source set. Use flyio_set_datasource to set the data source."))
  return(data_source)
}
