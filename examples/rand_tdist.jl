using Distributions, ZVSimulator

distributions = [TDist(5.) for i = 1:5]

results = psim_rand_vrf(distributions)

# writedlm_vrf(results, "./", ' ')
# writedlm_reformat("_means.txt", "./_means_pprint.txt", fill("%.3e", 3))
