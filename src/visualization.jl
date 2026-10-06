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
	plothandle, XY, levelsetcase; kwargs... ) where T <: H0representativePoint

	if levelsetcase == true
	labels = Vector{String}(undef, length(reps))

	for i = 1:length(reps)
		labels[i] = "$(i)"
	end

	coordinates = getindex.(reps,1)
	
	Makie.scatter!(plothandle, XY[2][coordinates], XY[1][coordinates];
			markersize=5,
			color=1:length(reps), label = [colorValue => (; color = id) for (id, colorValue) in enumerate(labels)],kwargs...)

	Makie.annotation!(plothandle, XY[2][coordinates], XY[1][coordinates]; style = Ann.Styles.LineArrow(), color=:white, text = labels, textcolor=:white, shrink=(10,10),lineheight=1, kwargs...)
	end
	return plothandle
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
	reps :: H1representativeVector, 
	plothandle, XY, levelsetcase; kwargs... ) 

	if levelsetcase == true
		labels = Vector{String}(undef, length(reps))

		for i = 1:length(reps)
		labels[i] = "$(i)"
		end

		edges = Vector{Any}((undef), length(reps))

		for i in eachindex(reps)
			edges[i] = reps[i][1]
		end

		edges_all = []

		for i in eachindex(edges)
			push!(edges_all,[])
			for j in eachindex(edges_all[i])
			push!(edges_all[i], Point2f[(XY[2][edges[i][j][1]],XY[1][edges[i][j][1]]), (XY[2][edges[i][j][2]],XY[1][edges[i][j][2]])])
			end
		end

		for i = 1:length(edges_all)
			for j = 1:length(edges_all[i])
				lineseg_ax = push!(lineseg_ax[i], Makie.linesegments!(plothandle, edges_all[i][j]; linewidth = 1, kwargs...) )
			end
		end
	end

	return plothandle

end

"""
Plots sublevel (positive) and superlevel (negative) persistence diagrams, with the option of either swapping axes or signs for the negative PD.

# TODO At this point, it's not clear to me (=Marko) what should be the default

"""
function plotPDs( PD_pos, PD_neg; 
				  neg_swap_axes=false, neg_flip_sign=true, infinity=60, kwargs... )

	P = plot(PD_pos; markersize=7,
	seriescolor=[:blue, :green], label =["Subl. H0" "Subl. H1"], kwargs...)
	
	plot!(P, VortexTDA.flipPD.(PD_neg; axisswap=neg_swap_axes, signflip=neg_flip_sign);
			infinity= neg_flip_sign ? -infinity : infinity,	
			seriescolor=[:red, :orange], marker=:d, markersize=7,
			label =["Superl. H0" "Superl. H1"], 
			kwargs... )
	return P
end

function plotSnapshots(resolution, XY, field2D, methodID, panel, theta, j, nsnapshots, cut, axislim_plus, axislim_minus)
	f = Makie.Figure(size=resolution)
	leg = f[1,1]
	ax = f[1,2]
	snapshotax = Make.Axis(ax, title = "Homology Snapshot: $(methodID) \n Panel $(panel) — θ = $(theta)° | Snapshot: $(j)/$(nsnapshots) | Cutoff = $(cut) \n pad = Inf", 
					   xlabel = L"x/c", 
					   ylabel = L"y/c"
					  )
	
	heatmapax = heatmap!(snapshotax,XY[2].v, XY[1].v,transpose(field2D),colormap="vik10", colorrange=(axislim_minus,axislim_plus),lowclip=:white)
	
	Colorbar(f[:, end+1],heatmapax)

	leg = Makie.Legend(f, ax, L"H_0", framevisible = false)
	return f
end

