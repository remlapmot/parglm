rmarkdown::render("vignettes/parglm.Rmd.orig", output_file = "parglm.html")
file.copy("vignettes/parglm.html", "pkgdown/assets/articles/parglm.html", overwrite = TRUE)
