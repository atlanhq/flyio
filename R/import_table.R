#' Read csv, Excel files, txt
#' @description Read tabular data from anywhere using a function defined by you
#'
#' @param file path of the file to be read
#' @param FUN the function using which the file is to be read
#' @param data_source the name of the data source, if not set globally. s3, gcs or local
#' @param bucket the name of the bucket, if not set globally
#' @param dir the directory to store intermediate files
#' @param delete_file logical. to delete the file downloaded
#' @param ... other parameters for the FUN function defined above
#'
#' @export "import_table"
#' @return the output of the FUN function
#'
#' @examples
#' # for data on local
#' filepath = system.file("extdata", "mtcars.csv", package = "flyio")
#' data = import_table(filepath, data_source = "local")
#' \dontrun{
#' # for data on cloud
#' flyio_set_datasource("gcs")
#' flyio_set_bucket("your-bucket-name")
#' data = import_table("excel-file-on-gcs.xlsx", read_excel, dir = tempdir())
#' }

import_table <- function(file, FUN = read.csv, data_source = flyio_get_datasource(),
                         bucket = flyio_get_bucket(data_source), dir = flyio_get_dir(), delete_file = TRUE, ...){
  # checking if the file is valid
  #assert_that(tools::file_ext(file) %in% c("csv", "xlsx", "xls", "txt"), msg = "Please input a valid path")
  if(data_source == "local"){
    t = FUN(file, ...)
    return(t)
  }
  # a tempfile with the required extension
  temp <- paste0(dir, "/", basename(file))
  if(isTRUE(delete_file)){on.exit(unlink(temp))}
  # downloading the file
  file = gsub("\\/+","/",file)
  downlogical = import_file(bucketpath = file, localfile = temp, data_source = data_source, bucket = bucket)
  assert_that(is.character(downlogical), msg = "Downloading of file failed")
  # loading the file to the memory using user defined function
  result = FUN(temp, ...)
  return(result)
}

