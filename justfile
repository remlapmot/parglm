render: install
    time Rscript vignettes/precompile.R && oxipng vignettes/img/*.png
blas:
    ln -sf libRblas.vecLib.dylib "$(Rscript -e 'cat(R.home("lib"))')/libRblas.dylib"
    Rscript -e 'cat(extSoftVersion()[["BLAS"]], "\n")'
blas-ref:
    ln -sf libRblas.0.dylib "$(Rscript -e 'cat(R.home("lib"))')/libRblas.dylib"
    Rscript -e 'cat(extSoftVersion()[["BLAS"]], "\n")'
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
build: docs render
    Rscript -e "devtools::build()"
install:
    Rscript -e "devtools::install()"
