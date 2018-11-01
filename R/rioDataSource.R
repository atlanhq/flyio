#' Set global DataSource name for rIO
#' @description Set global DataSource name to be used for all the function in rIO
#' @param DataSource the DataSource name to be set
#'
#' @return stores the DataSource name in a global environment under rioDataSource
#' @export "rioSetDataSource"
#' @import "stringr"
#' @examples rioSetDataSource("local")
rioSetDataSource <- function(data_source){
  invisible(assert_that(is.string(data_source) && str_to_lower(data_source) %in% c("gcs", "s3", "local"), msg = "Enter a valid data source name"))
  data_source = str_to_lower(data_source)
  Sys.setenv("rioDataSource" = data_source)
  message("Default Data Source name set to '",data_source,"'")
}

#' Get global Data Source name for rIO
#' @description Get global data source name to be used for all the function in rIO. Returns the value stored using rioSetDataSource
#' @return the string - DataSource name stored
#' @export "rioGetDataSource"
#'
#' @examples rioGetDataSource()
rioGetDataSource <- function(){
  data_source = Sys.getenv("rioDataSource")
  invisible(assert_that(is.string(data_source) && data_source != "", msg = "No data source set. Use rioSetDataSource to set the data source."))
  return(data_source)
}
