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

"""
function getH0representativePoint( PI::PersistenceDiagrams.PersistenceInterval, which )

Return a vector of pairs (CartesianIndices, Float)
for a representative gridpoint corresponding to the PersistenceInterval.

If which = :max, return gridpoint with max birth time.
If which = :min, return gridpoint with min birth time.

At its output, it creates H0representativePoint vector.
"""
function getH0representativePoint( PI::PersistenceDiagrams.PersistenceInterval, which=:min)

	reprRaw = PI.representative;
	reprVertexIdx = vertices.(reprRaw) # vector of single-element tuples
	reprVertexIdx = getindex.(reprVertexIdx,1) # extract the (only) element from each tuple
	#reprVertexIdx is a Vector of CartesianIndices pairs 
	birthValue = birth.(reprRaw)
	# values of the field that vertices take

	# selection of the gridpoint as either grid point with largest or smallest field value
	if which == :max
		sel_value, sel_idx = findmax(birthValue)
	elseif which == :min
		sel_value, sel_idx = findmin(birthValue)
	else
		error("Unknown selection method for the vertex")
	end

	return reprVertexIdx[sel_idx], sel_value

end

"""
function getH1vectorRepresentative( PI::PersistenceDiagrams.PersistenceInterval, which )

Return a vector of pairs (Vector{CartesianIndex{2}}, Float)
for a representative gridpoint corresponding to the PersistenceInterval.

If which = :max, return gridpoint with max birth time.
If which = :min, return gridpoint with min birth time.

At its output, it creates H0representativePoint vector.
"""
function getH1representativeVector( PI::PersistenceDiagrams.PersistenceInterval )

	reprRaw = PI.representative;
	reprVertexIdx = vertices.(reprRaw) # vector of single-element tuples
	#reprVertexIdx is a Vector of CartesianIndices pairs 
	birthValue = birth.(reprRaw)
	# values of the field that vertices take


	return reprVertexIdx, birthValue

end
