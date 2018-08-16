#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param file PARAM_DESCRIPTION
#' @param transfer PARAM_DESCRIPTION, Default: 'YES'
#' @param transfer_time PARAM_DESCRIPTION, Default: 'ON_EXIT'
#' @param job_type  PARAM_DESCRIPTION, Default: 'standard'
#' @param args PARAM_DESCRIPTION, Default: '$(Process)'
#' @param tag PARAM_DESCRIPTION, Default: 'job'
#' @param init_dir PARAM_DESCRIPTION, Default: 'jobs'
#' @param input_files PARAM_DESCRIPTION, Default: NULL
#' @param output_files PARAM_DESCRIPTION, Default: NULL
#' @param jobs PARAM_DESCRIPTION, Default: 1
#' @param template_file character, path to save the template file, Default: NULL
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @seealso
#'  \code{\link[whisker]{whisker.render}}
#' @rdname build_template
#' @export
#' @importFrom whisker whisker.render
build_template <- function(
  file,
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
      username = system2("whoami", stdout = TRUE),
      transfer_time = transfer_time,
      args = paste0(args,collapse = ' '),
      tag=tag,
      init_dir = init_dir,
      input_files = paste0(input_files,collapse = ' '),
      output_files = paste0(output_files,collapse = ' '),
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
