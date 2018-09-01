## ----setup, include = FALSE----------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----remedy001-----------------------------------------------------------
#  library(condor)
#  library(ssh)
#  

## ----remedy002-----------------------------------------------------------
#  condor::build_template(
#    file = 'calcpi.R',
#    args = c('$(Process)'),
#    tag = 'pi',
#    jobs = 5,
#    init_dir = 'jobs/run',
#    template_file = 'example/Rcalcpi.condor',
#    job_type = 'test')
#  
#  

## ----eval = TRUE---------------------------------------------------------
readLines(system.file('example/calcpi.R',package='condor'))

## ----eval = TRUE---------------------------------------------------------
readLines(system.file('example/Rcalcpi.condor',package='condor'))

## ----remedy003-----------------------------------------------------------
#  session <- ssh::ssh_connect(Sys.getenv('UCONN_USER'))
#  

## ----remedy004-----------------------------------------------------------
#  ssh::scp_upload(session,
#                  files = c('example/calcpi.R',
#                            'example/Rcalcpi.condor',
#                            'example/emailMyself.txt'),
#                  to = '~'
#  )
#  

## ----remedy005-----------------------------------------------------------
#  condor::create_dirs(session, file = 'example/Rcalcpi.condor')
#  

## ----remedy006-----------------------------------------------------------
#  condor::condor_submit(session,'Rcalcpi.condor')
#  

## ----remedy007-----------------------------------------------------------
#  condor::condor_q(session)
#  

## ------------------------------------------------------------------------
#  condor::condor_rm(session,'5000.1')
#  

## ----remedy008-----------------------------------------------------------
#  condor::pull(session,
#               from = c('jobs/run/log',
#                        'jobs/run/out',
#                        'jobs/run/err',
#                        'jobs/run/*.rds'),
#               to = c('output',
#                      'output',
#                      'output',
#                      'output/data'))
#  

## ----remedy009-----------------------------------------------------------
#  condor::cleanup_remote(session)
#  

## ----remedy010-----------------------------------------------------------
#  RETURN <- purrr::map(
#    list.files(path = "example/output/data",full.names = TRUE),
#    readRDS
#    )
#  

## ----remedy011-----------------------------------------------------------
#  condor::cleanup_local(dir = 'example/output',tag = 'pi')
#  

## ----remedy012-----------------------------------------------------------
#  ssh::ssh_disconnect(session)
#  

