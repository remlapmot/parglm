render:
    Rscript vignettes/precompile.R
opt:
    oxipng vignettes/img/*.png
check:
    R -e "devtools::check()"
test:
    R -e "devtools::test()"
doc:
    R -e "devtools::document()"
