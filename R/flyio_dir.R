#' Set global directory for flyio to store data
#' @description Set global directory where flyio functions will download intermidiate files
#'
#' @return stores the directory in a global environment under CLOUD_DIR
#' @export "flyio_set_dir"
#' @import "assertthat"
#'
#' @examples flyio_set_dir(dir = tempdir())
flyio_set_dir <- function(dir = paste0(tempdir(), "/flyio",Sys.getpid())){
  if(dir == paste0(tempdir(), "/flyio",Sys.getpid()) & !dir.exists(paste0(tempdir(), "/flyio",Sys.getpid()))){
    dir.create(paste0(tempdir(), "/flyio",Sys.getpid()))
  }
  assert_that(is.dir(dir), msg = "Enter a valid directory name")
  Sys.setenv("CLOUD_DIR" = normalizePath(dir, mustWork = FALSE))
  message("Default directory name for flyio set to '",dir,"'")
}

#' Get global bucket name for flyio
#' @description Get global directory where flyio functions will download intermidiate files
#' @return the string - directory name
#' @details if the directory is not set using flyio_set_dir(), it will return the paste0(tempdir(),"/flyio")
#' @export "flyio_get_dir"
#'
#' @examples
#' flyio_get_dir()
flyio_get_dir <- function(){
  dir = Sys.getenv("CLOUD_DIR")
  if(dir == ""){
    tmpdir = normalizePath(tempdir(), mustWork = FALSE)
    dir = paste0(tmpdir, "/flyio",Sys.getpid())
  }
  if(dir == paste0(tmpdir, "/flyio",Sys.getpid()) & !dir.exists(paste0(tmpdir, "/flyio",Sys.getpid()))){
    dir.create(paste0(tmpdir, "/flyio",Sys.getpid()))
  }
  return(dir)
}
