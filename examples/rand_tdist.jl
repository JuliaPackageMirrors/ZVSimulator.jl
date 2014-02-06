using Distributions, ZVSimulator

d = TDist(5.)

results = psim_rand_vrf(d, nsets=5)

# writedlm_vrf(results, "./", ' ')
# writedlm_reformat("_means.txt", "./_means_pprint.txt", fill("%.3e", 3))
