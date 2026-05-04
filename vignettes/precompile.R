# Precompile vignette
# Must move image files from top level to vignettes/ after knit

if (!requireNamespace("parglm")) stop("Remember to install parglm itself!")
# Build/install the package first (equivalent to RStudio Build > Install):
#   devtools::install()
# or:
#   pak::local_install()
# or from the shell:
#   R CMD INSTALL .

knitr::knit("vignettes/parglm.Rmd.orig", output = "vignettes/parglm.Rmd")
pngs <- list.files("img", pattern = "\\.png$", full.names = TRUE)
if (length(pngs) > 0) {
  dir.create("vignettes/img", showWarnings = FALSE, recursive = TRUE)
  file.rename(pngs, file.path("vignettes", pngs))
  unlink("img", recursive = TRUE)
}
