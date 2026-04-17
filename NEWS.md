# parglm 0.1.8
* Remove specification of C++11
* Amend `std::result_of` to `std::invoke_result` in a header file
* Fix infinite recursion in `QR_base::qyt` by removing `std::move`
* Require C++17 on Linux, macOS, and Windows
* New maintainer - Tom Palmer

# parglm 0.1.7
* Avoid some virtual function calls and remove a few macros. 
* Fix an issue due to the new `STRICT_R_HEADERS` variable in Rcpp.

# parglm 0.1.6
* Avoid some memory allocations.
* Fix a test issue with ATLAS.

# parglm 0.1.4
* `stop`s when there are more variables than observations. Previously, this 
  caused a crash.
* Handle Fortran string length argument.

# parglm 0.1.3
* Fix bug found with Valgrind.

# parglm 0.1.2
* Minor changes in implementation.
* Fix bugs in patched R and oldrel R.

# parglm 0.1.1
* A `FAST` method is added which computes the Fisher information and then solves 
  the normal equation as in `speedglm`. 
* One change which decreased the computation time.
* Minor bug fixes.
