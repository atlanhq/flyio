#' Set global DataSource name for flyio
#' @description Set global DataSource name to be used for all the function in flyio
#' @param data_source the DataSource name to be set
#'
#' @return stores the DataSource name in a global environment under rioDataSource
#' @export "flyio_set_datasource"
#' @import "stringr"
#' @examples flyio_set_datasource("local")
flyio_set_datasource <- function(data_source){
  invisible(assert_that(is.string(data_source) && str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Enter a valid data source name"))
  data_source = str_to_lower(data_source)
  Sys.setenv("rioDataSource" = data_source)
  message("Default Data Source name set to '",data_source,"'")
}

#' Get global Data Source name for flyio
#' @description Get global data source name to be used for all the function in flyio. Returns the value stored using flyio_set_datasource
#' @return the string - DataSource name stored
#' @export "flyio_get_datasource"
#'
#' @examples
#' # first setting the data source
#' flyio_set_datasource("s3")
#' # getting the data source
#' flyio_get_datasource()
flyio_get_datasource <- function(){
  data_source = Sys.getenv("rioDataSource")
  invisible(assert_that(is.string(data_source) && data_source != "", msg = "No data source set. Use flyio_set_datasource to set the data source."))
  return(data_source)
}
