#' @inherit magrittr::'%>%'
#' @importFrom magrittr %>%
#' @name %>%
#' @rdname pipe
#' @export
NULL

#' @title condor_q
#' @description invokes condor_q on the cluster
#' @param session session connection object
#' @return character
#' @examples
#' \dontrun{
#' condor_q(session)
#' }
#' @seealso
#'  \code{\link[ssh]{ssh_exec}}
#' @rdname condor_q
#' @export
#' @importFrom ssh ssh_exec_wait
condor_q <- function(session){
  ssh::ssh_exec_wait(session, command = 'condor_q')
}

#' @title condor_submit
#' @description submits jobs on the the cluster
#' @param session session connection object
#' @param file character, condor file on the cluster
#' @param notify boolean, notify by email at the end of the jobs, Default: TRUE
#' @param \dots arguments to pass to [make_check_jobs][condor::make_check_jobs]
#' @return ssh result from the call
#' @examples
#' \dontrun{
#' condor_submit(session,'file.condor')
#' }
#' @seealso
#'  \code{\link[ssh]{ssh_exec}}
#' @rdname condor_submit
#' @export
#' @importFrom ssh ssh_exec_wait
condor_submit <- function(session,file,notify = TRUE,...){

  ssh::ssh_exec_wait(session, command = sprintf('condor_submit %s',file))

  if(notify){
    make_check_jobs(session,...)
    ssh::ssh_exec_wait(session,
                       command = 'nohup bash check_jobs.sh > check_jobs.out 2>&1 &')
  }
}

#' @title set permissions for files on the cluster
#' @description wrapper that sets permissions for files on the cluster
#' @param session session connection object
#' @param file character, filename to set permissions
#' @param permission character, permissions to set, Default: 'a+x'
#' @return ssh result from the call
#' @examples
#' \dontrun{
#' condor_permissions(session,'file.r','a+x')
#' }
#' @seealso
#'  \code{\link[ssh]{ssh_exec}}
#' @rdname condor_permissions
#' @export
#' @importFrom ssh ssh_exec_wait
condor_permissions <- function(session,file,permission = 'a+x'){
  ssh::ssh_exec_wait(session, command = sprintf('chmod %s %s',permission,file))
}

#' @title condor_rm
#' @description invokes condor_rm on the cluster
#' @param session session connection object
#' @param jobs character/numeric, jobs to kill
#' @return result of call
#' @examples
#' \dontrun{
#' condor_rm(session,5000) # set of jobs
#' condor_rm(session,5000.1) # specific job
#' }
#' @seealso
#'  \code{\link[ssh]{ssh_exec}}
#' @rdname condor_rm
#' @export
#' @importFrom ssh ssh_exec_wait
condor_rm <- function(session,jobs){
  ssh::ssh_exec_wait(session, command = sprintf('condor_rm %s',paste0(jobs,collapse = ' ')))
}

#' @title cleanup files on the cluster
#' @description post processing function to cleanup files used
#'   for the jobs on the master.
#' @param session session connection object
#' @param dir character, path that jobs were invoked from on the master, Default: 'jobs/run'
#' @return ssh result from the call
#' @examples
#' \dontrun{
#' cleanup_remote(session,'jobs/run')
#' }
#' @seealso
#'  \code{\link[ssh]{ssh_exec}}
#' @rdname cleanup_remote
#' @export
#' @importFrom ssh ssh_exec_wait
cleanup_remote <- function(session, dir = 'jobs/run'){
  ssh::ssh_exec_wait(session, command = sprintf('rm -r -f %s', dir))
  ssh::ssh_exec_wait(session, command = sprintf('rm *.R'))
  ssh::ssh_exec_wait(session, command = sprintf('rm *.condor'))
}

#' @title cleanup files on the local machine
#' @description post processing function to cleanup files used
#'   for the jobs on the local machine.
#' @param dir character, path where the jobs were returned on the local machine
#' @param tag character, tag name given to the jobs.
#' @return NULL
#' @examples
#' \dontrun{
#' cleanup_local('path','tag')
#' }
#' @rdname cleanup_local
#' @export
cleanup_local <- function(dir,tag){

  x <- list.files(
    dir,
    pattern = tag,
    recursive = TRUE,
    full.names = TRUE)

  invisible(sapply(x,unlink,force = TRUE))

  cat(c('Removed files:',x),sep='\n')
}

#' @title Create directories on the cluster
#' @description Create relevant directories for job outputs based on the
#' condor.file fields.
#' @param session session connection object
#' @param file character, path to condor file on local machine
#' @return ssh result from the call
#' @examples
#' \dontrun{
#' create_dirs(session,'run.condor')
#' }
#' @seealso
#'  \code{\link[ssh]{ssh_exec}}
#' @rdname create_dirs
#' @export
#' @importFrom ssh ssh_exec_wait
create_dirs <- function(session, file){
  x <- readLines(file,warn = FALSE)
  initialdir <- lookup('initialdir',x)
  output <- file.path(initialdir,dirname(lookup('output',x)))
  error <- file.path(initialdir,dirname(lookup('error',x)))
  log <- file.path(initialdir,dirname(lookup('log',x)))


  ssh::ssh_exec_wait(session,
                command = c(
                  sprintf('mkdir %s', initialdir),
                  sprintf('mkdir %s', log),
                  sprintf('mkdir %s', output),
                  sprintf('mkdir %s', error)
                  )
                )

  executable <- lookup('executable',x)

  condor_permissions(session,executable)

}

#' @title pull files from cluster to local machine
#' @description wrapper of [scp_download][ssh::scp_download] to pull files from
#' cluster to the local machine
#' @param session session connection object
#' @param from character, path on cluster
#' @param to character, path on local machine
#' @return ssh result from the call
#' @examples
#' \dontrun{
#' pull(session, from = 'cluster_file.R', to = 'local_file.R')
#' }
#' @seealso
#'  \code{\link[purrr]{map2}}
#'  \code{\link[ssh]{scp}}
#' @rdname pull
#' @export
#' @importFrom purrr walk2
#' @importFrom ssh scp_download
pull <- function(session, from, to){
  purrr::walk2(from,to,
               .f=function(x,y){
                 ssh::scp_download(session,files = x,to = y)
               })
}

lookup <- function(pattern, x){
  ret <- gsub('^(.*?)=','',x[grep(sprintf('^%s',pattern),x)])
  gsub('^\\s+|\\s$','',ret)
}

#' @title run terminal command on cluster
#' @description wrapper to run command on the terminal of the cluster
#' @param session session connection object
#' @param .f command to run, Default: 'whoami'
#' @param intern boolean, switch between [ssh_exec_internal][ssh::ssh_exec_internal]
#' and [ssh_exec_wait][ssh::ssh_exec_wait]
#' @param convert_intern boolean, convert raw output from
#' [ssh_exec_internal][ssh::ssh_exec_internal] into human readable objects, Default: TRUE
#' @param \dots parameter to pass to ssh function
#' @return ssh result from the command
#' @examples
#' \dontrun{
#' ssh_fn(session,.f='ls ~')
#' ssh_fn(session,.f='ls ~',intern = TRUE)
#' }
#' @seealso
#'  \code{\link[ssh]{ssh_exec}}
#' @rdname ssh_fn
#' @export
#' @importFrom ssh ssh_exec_wait ssh_exec_internal
ssh_fn <- function(session,.f = 'whoami', intern= FALSE, convert_intern = TRUE,...){

  if(intern){

    ret <- ssh::ssh_exec_internal(session, command = .f, ...)

    if(convert_intern){
      return(ssh_print(ret$stdout))
    }else{
      return(ret)
    }

  }else{

    ssh::ssh_exec_wait(session, command = .f, ...)

  }

}

#' @title print for ssh_exec_internal call
#' @description converts raw output into characters
#' @param x ssh_exec_internal output
#' @return character
#' @rdname ssh_print
#' @export
ssh_print <- function(x){
  unlist(
    strsplit(
      rawToChar(x),
      '\\n')
  )
}
