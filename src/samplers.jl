function sample_serialmc(t::MCMCTask; rate::Bool=true)
  chain = MCMC.run_serialmc_exit(t)

  if isa(t.sampler, RWM) || isa(t.sampler, RAM)
    nsamples, npars = size(chain.samples)
    chain.gradients = Array(Float64, nsamples, npars)
    for i = 1:npars; chain.gradients[i, :] = t.model.evalg(chain.samples[:, i]); end
  end

  if rate; merge!(chain.diagnostics, ["rate"=>acceptance(chain)]); end

  ZVSample(chain)
end

function zvmean(samples::Matrix{Float64}, gradients::Matrix{Float64}; lzv::Bool=true, qzv::Bool=true)
  npars = size(samples, 2)

  means = Array(Float64, npars, 3)
  means[:, 1] = mean(samples, 1)
  means[:, 2] = lzv ? mean(linearZv(samples, gradients)[1], 1) : fill(NaN, npars)
  means[:, 3] = qzv ? mean(quadraticZv(samples, gradients)[1], 1) : fill(NaN, npars)

  ZVMean(means)
end

function zvmean(zvsample::ZVSample; lzv::Bool=true, qzv::Bool=true)
  zvmeans = zvmean(zvsample.samples, zvsample.gradients; lzv=lzv, qzv=qzv)
  zvmeans.diagnostics = zvsample.diagnostics
  zvmeans
end

sample_serialmc_zvmean(t::MCMCTask; rate::Bool=true, lzv::Bool=true, qzv::Bool=true) =
  zvmean(sample_serialmc(t; rate=rate); lzv=lzv, qzv=qzv)
