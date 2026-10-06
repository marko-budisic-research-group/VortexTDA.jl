module VortexTDA

using Ripserer
using PersistenceDiagrams
using Plots
using LaTeXStrings
using Makie

include("preprocessing.jl")
include("persistencehomology.jl")
include("visualization.jl")
include("vortexIDsetup.jl")

export cubicalhomology
export cubicalcohomology

end # module VortexTDA
