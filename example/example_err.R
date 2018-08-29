library(condor)

build_template(
  file = 'calcpi.R',
  args = c('$(Process)'),
  tag = 'pi',
  jobs = 5,
  init_dir = 'jobs/run',
  template_file = 'example/Rcalcpi.condor',
  job_type = 'test')


library(ssh)

session <- ssh::ssh_connect(Sys.getenv('UCONN_USER'))

ssh::scp_upload(session,
                files = c('example/calcpi.R','example/Rcalcpi.condor', 'example/emailMyself.txt'),
                to = '~'
)

condor::create_dirs(session, file = 'example/Rcalcpi.condor')

condor::condor_submit(session,'Rcalcpi.condor')

condor::condor_q(session)

#my laptop
#dir.create('example/output/data',recursive = TRUE)

condor::pull(session,
             from = c('jobs/run/log',
                      'jobs/run/out',
                      'jobs/run/err',
                      'jobs/run/*.rds'),
             to = c('output',
                    'output',
                    'output',
                    'output/data'))

