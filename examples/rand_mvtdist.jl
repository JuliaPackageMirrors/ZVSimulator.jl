using Distributions, ZVSimulator

function C(n::Int, c::Float64)
  X = eye(n)
  [(j <= n-i) ? X[i+j, i] = X[i, i+j] = c^j : nothing for i = 1:(n-1), j = 1:(n-1)]
  X
end

df, npars, a = 5., 4, 0.25
c = ((df-2)/df)*C(npars, a)

distributions = [MvTDist(df, zeros(npars), c) for i = 1:5]

results = psim_rand_vrf(distributions)

# writedlm_vrf(results, "./", ' ')
# writedlm_reformat("_means.txt", "./_means_pprint.txt", fill("%.3e", 3))
