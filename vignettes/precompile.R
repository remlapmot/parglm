# Precompile vignette
# Must move image files from top level to vignettes/ after knit

if (!requireNamespace("parglm")) stop("Remember to install parglm itself!")

# Benchmarks should use Apple's Accelerate BLAS on macOS. R upgrades reset the
# libRblas.dylib symlink to the reference BLAS; run `just blas` to fix it.
# Set PARGLM_ALLOW_REF_BLAS=true to deliberately render with another BLAS.
if (Sys.info()[["sysname"]] == "Darwin" &&
    !grepl("vecLib|Accelerate", extSoftVersion()[["BLAS"]]) &&
    !isTRUE(as.logical(Sys.getenv("PARGLM_ALLOW_REF_BLAS", "false"))))
  stop("R is not using the Accelerate BLAS (", extSoftVersion()[["BLAS"]],
       "). Run `just blas` or set PARGLM_ALLOW_REF_BLAS=true.")
# Build/install the package first (equivalent to RStudio Build > Install):
#   devtools::install()
# or:
#   pak::local_install()
# or from the shell:
#   R CMD INSTALL .

knitr::opts_chunk$set(cache.rebuild = TRUE) # uncomment to clear knitr cache
knitr::knit("vignettes/parglm.Rmd.orig", output = "vignettes/parglm.Rmd")
pngs <- list.files("img", pattern = "\\.png$", full.names = TRUE)
if (length(pngs) > 0) {
  dir.create("vignettes/img", showWarnings = FALSE, recursive = TRUE)
  file.rename(pngs, file.path("vignettes", pngs))
  unlink("img", recursive = TRUE)
}
