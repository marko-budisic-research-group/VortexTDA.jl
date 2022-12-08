function display_vorticity(XY,Vs; kwargs...)

    colorscale_extent = maximum( abs, Vs )

	plot_handle = heatmap(XY[2].v,XY[1].v, Vs; 
		fill=(true, cgrad([:blue, :transparent, :red])), 
        level=20, 
        legend = false, 
		colorbar = true, 
        xlabel=L"x/c", 
        ylabel=L"y/c", 
		background_color = :transparent, 
		aspect_ratio = :equal, 
        tickfont = (12, :black),
        xaxis = (tickfontrotation = 60.0),
		clim=(-colorscale_extent,colorscale_extent), 
        xlims=(0.0505,1.25), 
        ylims=(-1.6,1.6),
		size=(600,800), 
        foreground_color = :black, 
        dpi=300,
        kwargs...
	);
	return plot_handle
end

"""
For each representative point, plot a scatter plot on the plothandle axis, according to grid values stored in XY ndgrid
"""
function plotH0representativePoint!( 
	reps::Vector{T}, 
	plothandle, XY; kwargs... ) where T <: H0representativePoint


	coordinates = getindex.(reps,1)
	
	scatter!(plothandle, XY[2][coordinates], XY[1][coordinates];
			markersize=5,
			palette=:Set1_9, kwargs...)


end

"""
Version of the function when only a single interval was passed.
Simply creates a vector and passes to vector-based function.
"""
function plotH0representativePoint!( 
	rep :: T,  args...; kwargs... ) where T <: H0representativePoint


	println("Inside singleton")
	plotH0representativePoint!( [rep,], args...; kwargs...)

end 

"""
For each representative point, plot a scatter plot on the plothandle axis, according to grid values stored in XY ndgrid

# TODO Plot representative as a closed loop or a shape 
#   Right now the plotting is done by putting down a line for each edge
#   separately. It would be better if all edges were extracted in the 
#   appropriate order and then a single plot command per representative issued.

"""
function plotH1representativeVector!( 
	rep :: H1representativeVector, 
	plothandle, XY; kwargs... ) 

	[
	plot!(plothandle, 
		[XY[2][p] for p in edge],
		[XY[1][p] for p in edge],
		markersize=1, markercolor=:black,
		palette=:Set1_9; kwargs...)		
		for edge in rep[1]
	]

	return plothandle

end

