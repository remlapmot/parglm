render:
    Rscript -e "devtools::install()" && time Rscript vignettes/precompile.R && oxipng vignettes/img/*.png
opt:
    oxipng vignettes/img/*.png
check: docs
    Rscript -e "devtools::check()"
test:
    Rscript -e "devtools::test()"
docs:
    Rscript -e "devtools::document()"
clear:
    rm -rf cache
rhub:
    Rscript -e "rhub::rhub_check(platforms = c('atlas', 'c23', 'clang-asan', 'clang-ubsan', 'ubuntu-release', 'valgrind'))"
dev:
    Rscript -e "pak::local_install_dev_deps()"
