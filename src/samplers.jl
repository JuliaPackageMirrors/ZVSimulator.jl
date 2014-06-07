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

function sample_rand(d::MultivariateDistribution, nsamples::Int64)
  samples, gradients = Array(Float64, dim(d), nsamples), Array(Float64, dim(d), nsamples)

  for i = 1:nsamples
    samples[:, i] = rand(d)
    gradients[:, i] = gradlogpdf(d, samples[:, i])
  end

  ZVSample(samples', gradients')
end

function sample_rand(d::UnivariateDistribution, nsamples::Int64)
  samples, gradients = Array(Float64, nsamples), Array(Float64, nsamples)

  for i = 1:nsamples
    samples[i] = rand(d)
    gradients[i] = gradlogpdf(d, samples[i])
  end

  ZVSample(reshape(samples, nsamples, 1), reshape(gradients, nsamples, 1))
end

function zvmean(samples::Matrix{Float64}, gradients::Matrix{Float64};
  transform::Union(Function, Nothing)=nothing, lzv::Bool=true, qzv::Bool=true)
  transformed_samples = transform == nothing ? samples : transform(samples)
  npars = size(transformed_samples, 2)

  means = Array(Float64, npars, 3)
  means[:, 1] = mean(transformed_samples, 1)
  means[:, 2] = lzv ? mean(linearZv(transformed_samples, gradients)[1], 1) : fill(NaN, npars)
  means[:, 3] = qzv ? mean(quadraticZv(transformed_samples, gradients)[1], 1) : fill(NaN, npars)

  ZVMean(means)
end

function zvmean(zvsample::ZVSample; transform::Union(Function, Nothing)=nothing, lzv::Bool=true, qzv::Bool=true)
  zvmeans = zvmean(zvsample.samples, zvsample.gradients; transform=transform, lzv=lzv, qzv=qzv)
  zvmeans.diagnostics = zvsample.diagnostics
  zvmeans
end

sample_serialmc_zvmean(t::MCMCTask;
  transform::Union(Function, Nothing)=nothing, rate::Bool=true, lzv::Bool=true, qzv::Bool=true) =
  zvmean(sample_serialmc(t; rate=rate); transform=transform, lzv=lzv, qzv=qzv)

sample_rand_zvmean(d::Distribution, nsamples::Int64;
  transform::Union(Function, Nothing)=nothing, lzv::Bool=true, qzv::Bool=true) =
  zvmean(sample_rand(d, nsamples); transform=transform, lzv=lzv, qzv=qzv)
