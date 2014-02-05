my_tests = ["examples/mcmc_mvtdist.jl", "examples/rand_mvtdist.jl", "examples/rand_tdist.jl"]

println("Running tests:")

for my_test in my_tests
    println(" * $(my_test)")
    include(my_test)
end
