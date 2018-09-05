#' @title Summary of err files
#' @description Post processing summary containing all the unique errors and warnings
#' found in the err subdirectory.
#' @param err_path character, path to err subdirectory, Default: 'output/err'
#' @return character
#' @rdname read_errs
#' @export
#' @importFrom purrr map_chr
#' @importFrom tibble enframe
#' @importFrom dplyr group_by summarise ungroup pull
#' @importFrom rlang !! sym
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
  dplyr::group_by(!!rlang::sym('value'))%>%
  dplyr::summarise(name=paste0(!!rlang::sym('name'),collapse = ','))%>%
  dplyr::ungroup()%>%
  dplyr::summarise(s = sprintf('%s\n\n%s',!!rlang::sym('name'),!!rlang::sym('value')))%>%
  dplyr::pull(!!rlang::sym('s'))%>%
  writeLines()

}
