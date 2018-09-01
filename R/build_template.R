#' @title Build Condor File
#' @description Parameterized construction of a condor file.
#' @param file characer, filename of the R script to run on the cluster
#' @param username character, username on cluster,
#'   Default: system2("whoami", stdout = TRUE)
#' @param transfer character, transfer file back, Default: 'YES'
#' @param transfer_time character, when to transfer the file, Default: 'ON_EXIT'
#' @param job_type  character, type of cluster to use,
#'   Default: c('standard', 'test', 'short', 'long')
#' @param args character, arguments to pass to the worker nodes from condor,
#'   Default: '$(Process)'
#' @param tag character, name of job for subdirectory naming scheme,
#'   Default: 'job'
#' @param init_dir character, initial directory for condor to invoke script,
#'   Default: 'jobs'
#' @param input_files character, names of files to pass to the worker nodes,
#'   Default: NULL
#' @param output_files character, names of files to return from the worker nodes,
#'   Default: NULL
#' @param jobs numeric, number of nodes to run on, Default: 1
#' @param template_file character, name of the saved template file, Default: NULL
#' @return If template_file is NULL then the populated template is printed to the console.
#'
#' @details see
#' \href{http://research.cs.wisc.edu/htcondor/manual/v8.7/SubmittingaJob.html#x17-280002.5}{Condor User Manual}
#'  for full user manual on what can be put in a Condor submission file.
#' @examples
#' build_template(file='file.R')
#' @seealso
#'  \code{\link[whisker]{whisker.render}}
#' @rdname build_template
#' @export
#' @importFrom whisker whisker.render
build_template <- function(
  file,
  username = system2("whoami", stdout = TRUE),
  job_type = c('standard', 'test', 'short', 'long'),
  transfer = 'YES',
  transfer_time = 'ON_EXIT',
  args = '$(Process)',
  tag = 'job',
  init_dir = 'jobs',
  input_files = NULL,
  output_files = NULL,
  jobs = 1,
  template_file = NULL
){
  job_type <- match.arg(job_type)
  this_template <- whisker::whisker.render(
    template = readLines(system.file('template.condor',package = 'condor')),
    data = list(
      file = file,
      transfer = transfer,
      if_not_standard_job = ifelse(job_type == 'standard', '# ', ''),
      job_type = job_type,
      username = username,
      transfer_time = transfer_time,
      args = paste0(args,collapse = ' '),
      tag=tag,
      init_dir = init_dir,
      input_files = paste0(input_files,collapse = ', '),
      output_files = paste0(output_files,collapse = ', '),
      jobs = jobs
    )
  )

  x <- strsplit(this_template,'\n')[[1]]

  idx <- grep('= $',x)

  if(length(idx)>0){
    x[idx] <- sprintf('# %s',x[idx])
  }

  this_template <- paste0(x,collapse = '\n')

  if(!is.null(template_file)){
    cat(this_template, '\n', file = template_file)
  }else{
    cat(this_template, '\n')
  }

}
