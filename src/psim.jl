function psim_vrf(sample_function::Function, operands; diagnostics::Union(Vector{ASCIIString}, Nothing)=nothing)
  zvsamples = pmap(sample_function, operands)
  means = mean_of_zvmean(zvsamples)
  vars = var_of_zvmean(zvsamples, means=means)
  vrfs = vrf(vars)

  results = (ASCIIString=>Any)["means"=>means, "vars"=>vars, "vrfs"=>vrfs]
  if diagnostics!= nothing
    for d in diagnostics
      merge!(results, [d=>collect_diagnostic(zvsamples; diagnostic=d)])
    end
  end

  results
end

function psim_serialmc_vrf(tasks::Array{MCMCTask, 1};
  transform::Union(Function, Nothing)=nothing, rate::Bool=true,lzv::Bool=true, qzv::Bool=true)
  sample_function(t::MCMCTask) = sample_serialmc_zvmean(t::MCMCTask; transform=transform, rate=rate, lzv=lzv, qzv=qzv)
  diagnostics = rate == true ? ["rate"] : nothing 
  psim_vrf(sample_function, tasks; diagnostics=diagnostics)
end

function psim_serialmc_vrf(t::MCMCTask; nchains::Int64=100,
  transform::Union(Function, Nothing)=nothing, rate::Bool=true,lzv::Bool=true, qzv::Bool=true)
  sample_function(x::MCMCTask) = sample_serialmc_zvmean(x::MCMCTask; transform=transform, rate=rate, lzv=lzv, qzv=qzv)
  diagnostics = rate == true ? ["rate"] : nothing
  tasks = MCMCTask[t for i = 1:nchains]
  psim_vrf(sample_function, tasks; diagnostics=diagnostics)
end

function psim_rand_vrf{T<:Distribution}(dists::Array{T, 1}; nsamples::Int64=100,
  transform::Union(Function, Nothing)=nothing, rate::Bool=true,lzv::Bool=true, qzv::Bool=true)
  sample_function(d::Distribution) = sample_rand_zvmean(d, nsamples; transform=transform, lzv=lzv, qzv=qzv)
  psim_vrf(sample_function, dists)
end

function psim_rand_vrf(d::Distribution; nsets::Int64=100, nsamples::Int64=100,
  transform::Union(Function, Nothing)=nothing, rate::Bool=true,lzv::Bool=true, qzv::Bool=true)
  sample_function(x::Distribution) = sample_rand_zvmean(x, nsamples; transform=transform, lzv=lzv, qzv=qzv)
  dists = typeof(d)[d for i = 1:nsets]
  psim_vrf(sample_function, dists)
end
