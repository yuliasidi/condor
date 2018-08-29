#' @export
#' @importFrom whisker whisker.render
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
