#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param file PARAM_DESCRIPTION
#' @param transfer PARAM_DESCRIPTION, Default: 'YES'
#' @param transfer_time PARAM_DESCRIPTION, Default: 'ON_EXIT'
#' @param args PARAM_DESCRIPTION, Default: '$(Process)'
#' @param tag PARAM_DESCRIPTION, Default: 'job'
#' @param init_dir PARAM_DESCRIPTION, Default: 'jobs'
#' @param input_files PARAM_DESCRIPTION, Default: NULL
#' @param output_files PARAM_DESCRIPTION, Default: NULL
#' @param jobs PARAM_DESCRIPTION, Default: 1
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
