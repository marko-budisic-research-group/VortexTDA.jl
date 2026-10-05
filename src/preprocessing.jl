"""
Pad the field by frame of desired width containing specific value.
"""
	function pad_field_by_value(input; value=0, n_pixels=1)
		if value == "None"
			output = input
		elseif value == -Inf
			value = -value
			output = ones(size(input)[1]+n_pixels*2,size(input)[2]+n_pixels*2)*value
		output[(1+n_pixels):end-n_pixels,(1+n_pixels):end-n_pixels] = input
		else
		output = ones(size(input)[1]+n_pixels*2,size(input)[2]+n_pixels*2)*value
		output[(1+n_pixels):end-n_pixels,(1+n_pixels):end-n_pixels] = input
		end
		return output
	end

"""
Pad X/Y grid by adding a single "pixel" frame around them.

# TODO  merge pad_grid with pad_field_by_value
#   b/c how much we "extend" the grid depends on 
#   how thick of a frame we're adding to the field
"""
	function pad_grid(X,Y)
		delta_x = (X[3]-X[1])/2 # why not X[2]-X[1]?
		delta_y = (Y[3]-Y[1])/2
		Xx = append!([X[1]-delta_x], X, [X[end]+delta_x])
		Yy = append!([Y[1]-delta_y], Y, [Y[end]+delta_y])
		return Xx, Yy
	end

"""
	Determine the maximum/minimum values in the 2D field for plotting constraints
	"""
	function universalLims(t, snapshots)
		# to ensure all plots maintain same x,ylims
		store_Vorts = []
		rawstoreMin = []
		rawstoreMax = []
		storeMin = Float64[] #Array{Float32}(1, nsnapshots)
		storeMax = Float64[] #Array{Float32}(1, nsnapshots)
		storeMin_minus = Float64[] #Array{Float32}(1, nsnapshots)
		storeMax_minus = Float64[] #Array{Float32}(1, nsnapshots)

	
		matrix_key = :field2D_0
	
	
		for i in t
			searchLevelset_vort = get(snapshots[i], matrix_key,0)
			searchMin = findmin(searchLevelset_vort)
			searchMax = findmax(searchLevelset_vort)
	
			searchMin = searchMin[1]
			searchMax = searchMax[1]
			rawstoreMin = push!(rawstoreMin,searchMin)
			rawstoreMax = push!(rawstoreMax,searchMax)
			abs_searchMin = abs(searchMin)
			abs_searchMax = abs(searchMax)
		
			storeMin = push!(storeMin,abs_searchMin)
			storeMax = push!(storeMax,abs_searchMax)

			storeMin_minus = push!(storeMin_minus,searchMin)
			storeMax_minus = push!(storeMax_minus,searchMax)
		end

			resultMax = findmax(storeMax)
			resultMin = findmax(storeMin)

			resultMin_minus = findmin(storeMin_minus)
			resultMax_minus = findmin(storeMax_minus)

			axesLims_plus = max(resultMax[1], resultMin[1])
			#1.5 * ceil(max(resultMax[1], resultMin[1]) / 5)
			axesLims_minus = min(resultMax_minus[1], resultMin_minus[1])
			#1.5 * floor(min(resultMax_minus[1], resultMin_minus[1]) / 5)
		return axesLims_plus, axesLims_minus, rawstoreMax, rawstoreMin
	end