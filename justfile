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
clear:
    rm -rf cache
rhub:
    R -e "rhub::rhub_check(platforms = c('atlas', 'c23', 'clang-asan', 'clang-ubsan', 'ubuntu-release', 'valgrind'))"
