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