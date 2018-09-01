#' @title Build bash file to track jobs on Condor
#' @description Progrmatically build file to track Condor runs on the cluster.
#' @param session session object
#' @param sleeptime character, time interval to check if jobs are still running,
#'  Default: '10s'
#' @param email character, email address to send message on end of jobs,
#'  Default: Sys.getenv("UCONN_EMAIL")
#' @param subject character, subject line of the email, Default: 'auto email from stats cluster'
#' @param body character, body contents of the email,
#'  Default: 'All jobs have been completed.  Cheers!'
#' @return NULL
#' @examples
#' \dontrun{
#' make_check_jobs(session)
#' }
#' @seealso
#'  \code{\link[whisker]{whisker.render}}
#'  \code{\link[ssh]{scp}}
#' @rdname make_check_jobs
#' @export
#' @importFrom whisker whisker.render
#' @importFrom ssh scp_upload
make_check_jobs <- function(session,
                            sleeptime = '10s',
                            email = Sys.getenv('UCONN_EMAIL'),
                            subject = 'auto email from stats cluster',
                            body = 'All jobs have been completed.  Cheers!'){

  tf_mail <- file.path(tempdir(),'email_myself.txt')
  tf_sh <- file.path(tempdir(),'check_jobs.sh')

    on.exit({
      unlink(tf_mail)
      unlink(tf_sh)
      },add = TRUE)

  cat(
      whisker::whisker.render(template = readLines(system.file('email.tmpl',package = 'condor')),
                              data = list(email = email,subject = subject, body = body)),
      file = tf_mail,sep='\n')

  cat(
    whisker::whisker.render(template = readLines(system.file('check_jobs.tmpl',package = 'condor')),
                            data = list(sleeptime = sleeptime)),
    file = tf_sh,sep='\n')

  ssh::scp_upload(session,files = c(tf_mail,tf_sh),to = '~')

}
