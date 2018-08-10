build_template <- function(
  file,
  transfer = 'YES',
  transfer_time = 'ON_EXIT',
  args = '$(Process)',
  tag = 'job',
  init_dir = 'jobs',
  input_files = NULL,
  output_files = NULL,
  jobs = 1
){
  this_template <- whisker::whisker.render(
    template = readLines(system.file('template.condor',package = 'condor')),
    data = list(
      file = file,
      transfer = transfer,
      transfer_time = transfer_time,
      args = args,
      tag=tag,
      init_dir = init_dir,
      input_files = input_files,
      output_files = output_files,
      jobs = jobs
    )
  )

  cat(this_template)
}
