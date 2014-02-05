# Write chain means, VRFs and acceptance rates to files
function writedlm_vrf(results::Dict{ASCIIString, Any}, outdir::ASCIIString, fprefix::ASCIIString)
  for i in keys(results)
    writedlm(joinpath(outdir, fprefix*"_"*i*".txt"), results[i], ' ')
  end
end

# Read file and rewrite it into a new one with specified format
function writefmt(infile::ASCIIString, outfile::ASCIIString, outfmt::Array{ASCIIString, 1};
  indlm::ASCIIString=" ", outdlm::ASCIIString=" ", outendline::ASCIIString="\n")
  instream, outstream = open(infile), open(outfile, "w")

  while !eof(instream)
    inline, outline = readline(instream), string()
    if ismatch(r"[^\s\t\n\r]+", inline) && !ismatch(r"^#", inline)
      tokens = split(rstrip(inline), indlm)
      for i in 1:length(tokens)
        outline *= (@eval @sprintf($(outfmt[i]), parse($(tokens[i]))))*(i==length(tokens) ? outendline : outdlm)
      end
      write(outstream, outline)
    end
  end

  close(instream)
  close(outstream)
end
