library(condor)

args <- c('$(Process)')

tag <- 'iris'

jobs <- 5

initdir <- 'jobs/run'

transfer_input_files <- '../myfiles/lib/'

build_template(
  file = 'iris.R',
  args = args,
  tag = tag,
  jobs = jobs,
  init_dir = initdir,
  template_file = 'example/iris.condor',
  input_files = transfer_input_files)

library(ssh)

session <- ssh_connect(Sys.getenv('UCONN_USER'))

ssh::scp_upload(session,
           files = c('example/iris.R','example/iris.condor'),
           to = '~'
           )

condor::condor_permissions(session,file = 'iris.R')

condor::create_dirs(session, file = 'example/iris.condor')

condor::condor_submit(session,'iris.condor')

condor::condor_q(session)

#my laptop
#dir.create('example/output/data',recursive = TRUE)

condor::pull(session,
     from = c('jobs/run/log',
       'jobs/run/out',
       'jobs/run/err',
       'jobs/run/*.rds'),
     to = c('example/output',
            'example/output',
            'example/output',
            'example/output/data'))

condor::cleanup_remote(session)

condor::cleanup_local(dir = 'example/output',tag = 'iris')

ssh::ssh_disconnect(session)
