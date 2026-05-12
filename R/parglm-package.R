#' @keywords internal
#' @aliases parglm-package NULL
"_PACKAGE"

.onUnload <- function(libpath) {
  library.dynam.unload("parglm", libpath)
}
