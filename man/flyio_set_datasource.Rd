% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/flyio_datasource.R
\name{flyio_set_datasource}
\alias{flyio_set_datasource}
\title{Set global data source name for flyio}
\usage{
flyio_set_datasource(data_source)
}
\arguments{
\item{data_source}{the DataSource name to be set}
}
\value{
stores the data source name in a global environment under flyioDataSource
}
\description{
Set global data source name to be used for all the function in flyio
}
\examples{
flyio_set_datasource("local")
}
