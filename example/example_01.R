library(condor)

args <- c('10000000', 'pihat-$(Process).dat')

tag <- 'pi'

jobs <- 5

initdir <- 'jobs/run'

build_template(
  file = 'calcpi.R',
  args = args,
  tag = tag,
  jobs = jobs,
  template_file = 'example/Rcalcpi.condor')

library(ssh)

session <- ssh_connect(Sys.getenv('UCONN_USER'))

scp_upload(session,
           files = c('example/calcpi.R','example/Rcalcpi.condor'),
           to = '~'
           )

condor::condor_permissions(session,file = 'calcpi.R')

condor::condor_submit(session,'Rcalcpi.condor')

condor::condor_q(session)

dir.create('example/output/data',recursive = TRUE)

purrr::walk2(c('log','out','err','*.dat'),
             c('','','','data'),
            .f=function(x,y){
              scp_download(session,
               files = sprintf('jobs/run/%s',x),
               to = file.path('example/output',y)
               )
})

ssh_exec_wait(session, command = 'rm -r -f jobs/run')

ssh_disconnect(session)
