library(condor)

args <- c('$(Process)')

tag <- 'iris'

jobs <- 5

initdir <- 'jobs/run'

transfer_input_files <- 'jobs/ysidi/lib/'

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

scp_upload(session,
           files = c('example/iris.R','example/iris.condor'),
           to = '~'
           )

condor::condor_permissions(session,file = 'iris.R')

ssh_exec_wait(session,
              command = c('mkdir jobs/run',
                          'mkdir jobs/run/log',
                          'mkdir jobs/run/out',
                          'mkdir jobs/run/err'))

condor::condor_submit(session,'iris.condor')

condor::condor_q(session)

dir.create('example/output/data',recursive = TRUE)

purrr::walk2(c('log','out','err','*.rds'),
             c('','','','data'),
            .f=function(x,y){
              scp_download(session,
               files = sprintf('jobs/run/%s',x),
               to = file.path('example/output',y)
               )
})

ssh_exec_wait(session, command = 'rm -r -f jobs/run')

ssh_disconnect(session)
Dan
