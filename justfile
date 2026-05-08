render:
    R -e "devtools::install()" && time Rscript vignettes/precompile.R && oxipng vignettes/img/*.png
opt:
    oxipng vignettes/img/*.png
check:
    R -e "devtools::check()"
test:
    R -e "devtools::test()"
doc:
    R -e "devtools::document()"
