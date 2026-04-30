# Precompile vignette
# Must move image files from top level to vignettes/ after knit

if (!requireNamespace("parglm")) stop("Remember to install parglm itself!")
knitr::knit("vignettes/parglm.Rmd.orig", output = "vignettes/parglm.Rmd")
pngs <- c("figure/show_run_times-1.png")
file.rename(pngs, file.path("vignettes", pngs))
