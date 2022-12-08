"""
function cubicalhomology( field2D; kwargs... )

Compute cubical homology of a scalar field given by a matrix `field2D`.


"""
function cubicalhomology( field2D; kwargs... )

    cubicalComplex = Cubical(field2D)
    PH = ripserer(cubicalComplex;
        reps=true, alg=:homology,
        kwargs... )

end

