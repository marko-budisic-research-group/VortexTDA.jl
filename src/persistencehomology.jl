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


"""
function flipPD( input :: PersistenceDiagram; axisswap=true, signflip=true )

Swap the existing persistence diagram series so that instead of being plotted into top triangle of the 1st quadrant, it is plotted in the bottom triangle. Also flip sign of the interval values.

This is useful when one wants to plot both superlevel and sublevel set PD on the same graph. Sign flip is used when superlevel PD was computed as sublevel PD of a negative of the data.

TODO Look up in Dey or Rabadan or Edelsbrunner how this should be done properly (whether to only swap axes or also flip the sign).

TODO re-wrap this text.

"""
function flipPD( input :: PersistenceDiagram; axisswap=true, signflip=true )

	m = signflip ? -1 : 1;
	swap = axisswap ? reverse : x -> x;
	output = PersistenceDiagram(
		[ PersistenceInterval( swap(m.*pi)...; pi.meta...)   for pi in input ];
		input.meta ... 
	)

	return output

end
