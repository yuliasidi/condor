#' @export
#' @importFrom ssh ssh_exec_wait
condor_q <- function(session){
  ssh::ssh_exec_wait(session, command = 'condor_q')
}

#' @export
#' @importFrom ssh ssh_exec_wait
condor_submit <- function(session,file){
  ssh::ssh_exec_wait(session, command = sprintf('condor_submit %s',file))
}

#' @export
#' @importFrom ssh ssh_exec_wait
condor_permissions <- function(session,file,permission = 'a+x'){
  ssh::ssh_exec_wait(session, command = sprintf('chmod %s %s',permission,file))
}

#' @export
#' @importFrom ssh ssh_exec_wait
condor_rm <- function(session,jobs){
  ssh::ssh_exec_wait(session, command = sprintf('condor_rm %s',paste0(jobs,collapse = ' ')))
}

#' @export
#' @importFrom ssh ssh_exec_wait
cleanup_remote <- function(session, dir = 'jobs/run'){
  ssh::ssh_exec_wait(session, command = sprintf('rm -r -f %s', dir))
}

#' @export
cleanup_local <- function(dir,tag){

  x <- list.files(
    dir,
    pattern = tag,
    recursive = TRUE,
    full.names = TRUE)

  junk <- sapply(x,unlink,force = TRUE)

  cat(c('Removed files:',x),sep='\n')
}

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

}

#' @export
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
