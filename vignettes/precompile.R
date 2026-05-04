# Precompile vignette
# Must move image files from top level to vignettes/ after knit

if (!requireNamespace("parglm")) stop("Remember to install parglm itself!")
knitr::knit("vignettes/parglm.Rmd.orig", output = "vignettes/parglm.Rmd")
pngs <- list.files("figure", pattern = "\\.png$", full.names = TRUE)
if (length(pngs) > 0) {
  dir.create("vignettes/figure", showWarnings = FALSE, recursive = TRUE)
  file.rename(pngs, file.path("vignettes", pngs))
  unlink("figure", recursive = TRUE)
}
