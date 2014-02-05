function mean_of_zvmean(m)
  nsets = length(m)
  lzv = isnan((m[1].means)[1, 2]) ? false : true
  qzv = isnan((m[1].means)[1, 3]) ? false : true
  cols = (lzv ? (qzv ? (1:3) : (1:2)) : (qzv ? (1:2:3) : (1:1)))
  nmethods = cols.len
  mm = zeros(Float64, size(m[1].means, 1), nmethods)

  for i in 1:nsets
    mm += (m[i].means)[:, cols]
  end

  mm/nsets
end

function var_of_zvmean(m; means::Union(Matrix{Float64}, Nothing)=nothing)
  nsets = length(m)
  lzv = isnan((m[1].means)[1, 2]) ? false : true
  qzv = isnan((m[1].means)[1, 3]) ? false : true
  cols = (lzv ? (qzv ? (1:3) : (1:2)) : (qzv ? (1:2:3) : (1:1)))
  nmethods = cols.len
  v = zeros(Float64, size(m[1].means, 1), nmethods)

  mm = means == nothing ? mean_of_zvmean(m) : means
  for i in 1:nsets
    v += ((m[i].means)[:, cols]-mm).^2
  end

  v/(nsets-1)
end

function vrf(v)
  npars, nmethods = size(v)
  vrfs = Array(Float64, npars, nmethods-1)

  for i in 1:nmethods-1
    vrfs[:, i] = v[:, 1]./v[:, i+1]
  end

  vrfs
end

collect_diagnostic(m; diagnostic::ASCIIString="rate") = [(m[i].diagnostics)[diagnostic] for i in 1:length(m)]
