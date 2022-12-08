module VortexTDA

using Ripserer
using PersistenceDiagrams

using LaTeXStrings

include("preprocessing.jl")
include("persistencehomology.jl")
include("visualization.jl")

export cubicalhomology

end # module VortexTDA
