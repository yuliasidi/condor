#' @export
condor_q <- function(session) ssh_exec_wait(session, command = 'condor_q')

#' @export
condor_submit <- function(session,file){
  ssh_exec_wait(session, command = sprintf('condor_submit %s',file))
}

#' @export
condor_permissions <- function(session,file,permission = 'a+x'){
  ssh_exec_wait(session, command = sprintf('chmod %s %s',permission,file))
}

#' @export
condor_rm <- function(session,jobs){
  ssh_exec_wait(session, command = sprintf('condor_rm %s',paste0(jobs,collapse = ' ')))
}
