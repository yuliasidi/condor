#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param err_path PARAM_DESCRIPTION, Default: 'output/err'
#' @return OUTPUT_DESCRIPTION
#' @details DETAILS
#' @examples
#' \dontrun{
#' if(interactive()){
#'  #EXAMPLE1
#'  }
#' }
#' @rdname read_errs
#' @export
#' @importFrom purrr map_chr
#' @importFrom tibble enframe
#' @importFrom dplyr group_by summarise ungroup pull
read_errs <- function(err_path = 'output/err'){

err_files <- list.files(err_path,full.names = TRUE)

err_files <- err_files[file.info(err_files)['size']>0]

if(length(err_files)==0){
  message('No errors')
  return(invisible(NULL))
}


err_lines <- purrr::map_chr(err_files,function(x){
  paste0(readLines(x),collapse = '\n')
  })

names(err_lines) <- basename(err_files)

err_lines%>%
  tibble::enframe()%>%
  dplyr::group_by(value)%>%
  dplyr::summarise(name=paste0(name,collapse = ','))%>%
  dplyr::ungroup()%>%
  dplyr::summarise(s = sprintf('%s\n\n%s',name,value))%>%
  dplyr::pull(s)%>%
  writeLines()

}
