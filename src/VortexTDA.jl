module VortexTDA

using Ripserer
using PersistenceDiagrams

function cubicalhomology( field2D; kwargs... )

    cubicalComplex = Cubical(field2D)
    PH = ripserer(cubicalComplex;
        reps=true, alg=:homology,
        kwargs... )

end

export cubicalhomology

end # module VortexTDA
