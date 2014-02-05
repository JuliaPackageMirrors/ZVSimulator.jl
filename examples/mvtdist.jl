using Distributions, MCMC, ZVSimulator

function C(n::Int, c::Float64)
  X = eye(n)
  [(j <= n-i) ? X[i+j, i] = X[i, i+j] = c^j : nothing for i = 1:(n-1), j = 1:(n-1)]
  X
end

df, npars, a = 5., 4, 0.25
c = ((df-2)/df)*C(npars, a)

mcmodel = model(MvTDist(df, zeros(npars), c), init=zeros(npars))
samplers = [HMCDA() for i in 1:5]
tasks = mcmodel * samplers * SerialMC(steps=10000, burnin=1000)

zvout = psim_vrf(sample_serialmc_zvmean, tasks; diagnostics=["rate"])
