% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{condor_submit}
\alias{condor_submit}
\title{condor_submit}
\usage{
condor_submit(session, file, notify = TRUE, ...)
}
\arguments{
\item{session}{session connection object}

\item{file}{character, condor file on the cluster}

\item{notify}{boolean, notify by email at the end of the jobs, Default: TRUE}

\item{\dots}{arguments to pass to \link[condor:make_check_jobs]{make_check_jobs}}
}
\value{
ssh result from the call
}
\description{
submits jobs on the the cluster
}
\examples{
\dontrun{
condor_submit(session,'file.condor')
}
}
\seealso{
\code{\link[ssh]{ssh_exec}}
}
