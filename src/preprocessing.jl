"""
Pad the field by frame of desired width containing specific value.
"""
function pad_field_by_value(input; value=0, n_pixels=1)
	output = ones(size(input)[1]+n_pixels*2,size(input)[2]+n_pixels*2)*value
	output[(1+n_pixels):end-n_pixels,(1+n_pixels):end-n_pixels] = input
	return output
end

"""
Pad X/Y grid by adding a single "pixel" frame around them.

TODO: merge pad_grid with pad_field_by_value, b/c how much we "extend" the grid depends on how thick of a frame we're adding to the field
"""
function pad_grid(X,Y)
	delta_x = (X[3]-X[1])/2 # why not X[2]-X[1]?
	delta_y = (Y[3]-Y[1])/2
	Xx = append!([X[1]-delta_x], X, [X[end]+delta_x])
	Yy = append!([Y[1]-delta_y], Y, [Y[end]+delta_y])
	return Xx, Yy
end