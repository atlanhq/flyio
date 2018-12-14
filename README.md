# flyio - Make data fly to R <img src="https://i.imgur.com/XtsxAmX.png" align="right" />
Input and output data from R — download, upload, read and write objects from AWS S3, GoogleCloudStorage or local file system from a single interface.

## Overview

**flyio** provides a common interface to interact with data from cloud storage providers or local storage directly from R. It currently supports AWS S3 and Google Cloud Storage, thanks to the API wrappers provided by cloudyr. **flyio** also supports reading or writing tables, rasters, shapefiles and R objects to the data source from memory.

<img src="https://i.imgur.com/tdP2oxB.png" align="centre" />

  - `flyio_set_datasource()`: Set the data source (GCS, S3 or local) for all the other functions in flyio.
  - `flyio_auth()`: Authenticate data source (GCS or S3) so that you have access to the data. In a single session, different data sources can be authenticated.
  - `flyio_set_bucket()`: Set the bucket name once for any or both data sources so that you don't need to write it in each function.
  - `list_files()`: List the files in the bucket/folder.
  - `file_exists()`: Check if a file exists in the bucket/folder.
  - `export_file()`: Upload a file to S3 or GCS from R.
  - `import_file()`: Download a file from S3 or GCS. 
  - `import_[table/raster/shp/rds/rda]()`: Read a file from the set data source and bucket from a user-defined function.
  - `export_[table/raster/shp/rds/rda]()`: Write a file to the set data source and bucket from a user-defined function.
 
## Installation

Generate a personal access token, since this is a private repository: <br />
  - Go to https://github.com/settings/tokens. <br />
  - Click "Generate a personal access token".
  - Tick "repo". <br />
  - Scroll to the bottom and click "Generate token".<br />
  - Enter "flyio" in the token description box.<br />
  - Copy the token. <br />
<br />
In R, run the following command:

``` r
# Install the latest dev version from GitHub:
install.packages("devtools")
devtools::install_github("socialcopsdev/flyio", auth_token = "paste token copied above")

# Load the library
library(flyio)
```

### Example

``` r
# Setting the data source
flyio_set_datasource("gcs")

# Verify if the data source is set
flyio_get_datasource()

# Authenticate the default data source and set bucket
flyio_auth("key.json")
flyio_set_bucket("socialcops-flyio")

# Authenticate S3 also
flyio_auth(c("AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_DEFAULT_REGION", "AWS_SESSION_TOKEN"), data_source = "s3")
flyio_set_bucket("socialcops-flyio", data_source = "s3")

# Listing the files in GCS
list_files(path = "test", pattern = "*csv")

# Saving mtcars to all the data sources using default function write.csv
export_table(mtcars, "~/Downloads/mtcars.csv", data_source = "local")
export_table(mtcars, "test/mtcars.csv") # saving to GCS, need not mention as set globally
export_table(mtcars, "test/mtcars.csv", data_source = "s3")

# Check if the file written exists in GCS
file_exists("test/mtcars.csv")

# Read the file from GCS using readr library
mtcars <- import_table("test/mtcars.csv", FUN = readr::read_csv)

```

## References
* Cloudyr GCS wrapper: https://github.com/cloudyr/googleCloudStorageR
* Cloudyr S3 wrapper: https://github.com/cloudyr/aws.s3

<br/><br/>


<img src="http://i66.tinypic.com/29vjrjk.png" align="centre" />

