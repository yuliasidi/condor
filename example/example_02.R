library(condor)

build_template(
  file = 'iris.R',
  args = c('$(Process)'),
  tag = 'iris',
  jobs = 5,
  init_dir = 'jobs/run',
  template_file = 'example/iris.condor',
  input_files = c('../myfiles/lib/','iris_source.R'),
  job_type = 'test')

library(ssh)

session <- ssh_connect(Sys.getenv('UCONN_USER'))

ssh::scp_upload(session,
           files = c('example/iris.R','example/iris.condor'),
           to = '~'
           )

condor::create_dirs(session, file = 'example/iris.condor')

ssh::scp_upload(session,
                files = c('example/iris_source.R'),
                to = '~/jobs/run'
)

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

RETURN <- purrr::map(
  list.files(path = "example/output/data",full.names = TRUE),
  readRDS
  )

condor::cleanup_local(dir = 'example/output',tag = 'iris')

ssh::ssh_disconnect(session)
