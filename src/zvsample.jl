type ZVSample
  samples::Matrix{Float64}
  gradients::Matrix{Float64}
  diagnostics::Dict

  function ZVSample(samples::Matrix{Float64}, gradients::Matrix{Float64}, diagnostics::Dict)
    @assert size(samples) == size(gradients) "Samples and gradients must be of the same size"
    new(samples, gradients, diagnostics)
  end
end

ZVSample(samples::Matrix{Float64}, gradients::Matrix{Float64}) = ZVSample(samples, gradients, Dict())

ZVSample(chain::MCMCChain) = ZVSample(chain.samples, chain.gradients, chain.diagnostics)

type ZVMean
  means::Matrix{Float64}
  diagnostics::Dict
end

ZVMean(means::Matrix{Float64}) = ZVMean(means, Dict())
