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
