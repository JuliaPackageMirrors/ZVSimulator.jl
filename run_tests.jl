my_tests = ["examples/mcmc_mvtdist.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
