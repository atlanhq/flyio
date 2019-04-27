#' Set global directory for flyio to store data
#'
#' @description Set global directory where flyio functions will download intermidiate files
#' @param dir the directory to store intermediate files
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
  tmpdir = normalizePath(tempdir(), mustWork = FALSE)
  if(dir == ""){
    dir = paste0(tmpdir, "/flyio",Sys.getpid())
  }
  if(dir == paste0(tmpdir, "/flyio",Sys.getpid()) & !dir.exists(paste0(tmpdir, "/flyio",Sys.getpid()))){
    dir.create(paste0(tmpdir, "/flyio",Sys.getpid()))
  }
  return(dir)
}

#' List files in flyio tmp folder
#' @description Get the list of files downloaded by flyio in the default tmp folder
#' @return the string - file names
#' @export "flyio_list_dir"
#'
#' @examples
#' flyio_list_dir()
flyio_list_dir <- function(){
  tmpdir = normalizePath(tempdir(), mustWork = FALSE)
  dir = paste0(tmpdir, "/flyio",Sys.getpid())
  return(list.files(dir))
}

#' Delete files in flyio tmp folder
#' @description Delete the list of files downloaded by flyio in the default tmp folder
#' @return files deleted
#' @export "flyio_remove_dir"
#'
#' @examples
#' flyio_remove_dir()
flyio_remove_dir <- function(){
  tmpdir = normalizePath(tempdir(), mustWork = FALSE)
  dir = paste0(tmpdir, "/flyio",Sys.getpid())
  message("Deleting ", length(flyio_list_dir()), " files...")
  do.call(file.remove, list(list.files(dir, full.names = TRUE)))
}


