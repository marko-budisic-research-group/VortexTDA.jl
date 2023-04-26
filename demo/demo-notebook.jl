### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 032b2c0f-0c52-49dd-840d-65caa3ae7b9b
using Pkg

# ╔═╡ 4684f0f4-1fb0-4248-a6c8-3d129ebe6725
begin
	Pkg.develop("VortexTDA")
	Pkg.add("LaTeXStrings")
	Pkg.add("JLD2")
	Pkg.add("LazyGrids")
	Pkg.add("XLSX")
	Pkg.add("DataFrames")
end

# ╔═╡ 4d206232-f1e6-11ec-039a-776b65cfce0a
begin
	using Plots
	using MAT
	using Ripserer
	using PersistenceDiagrams
	using LaTeXStrings
	using DelimitedFiles
	using JLD2
	using Printf
	using LazyGrids
	using XLSX
	using DataFrames
	using Revise
end

# ╔═╡ 43e81d74-37d8-4574-b06e-a57be04fe6be
begin
	using PlutoUI
TableOfContents()
end

# ╔═╡ d17bfc41-9551-4b0b-b643-8a955fb492a0
# set all fonts in the Plots.jl to LaTeX-style fonts
Plots.default(fontfamily = "serif",tickfont = (12, :black))


# ╔═╡ 4bef167e-d811-4832-8646-3039409e012d
import VortexTDA

# ╔═╡ f7b9ed63-b559-4155-8389-dad59c66a5d1
Plots.gr()

# ╔═╡ f4f66a74-5a05-498a-b3db-b7973241429f
md"""
# Initial Setup
"""

# ╔═╡ a0c3e1b9-e996-45c1-b84a-70dd5ebba63a
md"""
## Panel parameters

  - Plate motion $(@bind caselabel Select([:Heaving,:Pitching,:HeavingAndPitching]))
  - Panel $(@bind panel PlutoUI.Slider(1:4,default=1, show_value=true))
"""

# ╔═╡ 523b6671-00c3-45c8-92ba-f8540829dcd7
begin
	CaseToFile = Dict( 
		:Heaving => 1,
		:Pitching => 2,
		:HeavingAndPitching => 3
	)
	clevel = 15
	panelc = [0.0505 0.0505 0.0505 0.0505]; #panel dimensions in graph between -0.0505 <= x <= 0.0505 and -0.0505 <= y <= 0.0505
	leftcut = [24 13 10 15]
	panelcase = "P$(panel)C$(CaseToFile[caselabel])"

end

# ╔═╡ 1c880145-d1d0-420b-af3f-f6a79d8d8e7c


# ╔═╡ fe829fc7-0b0e-43e9-87a4-bc69d1f48fa0
md"""
## Paths

Edit `toplevel` variable to point to "will" folder in Google Drive shared space.
"""

# ╔═╡ f6641248-3519-4c0f-b02b-a2e8343a9c6e
"""
Paths correspond to Alemni's folder.
"""
function alemnis_path(panelcase)
	toplevel = raw"C:\\Users\\yiran\\OneDrive\\Documents\\Research\\TDA\\raw_data\\Will"
	
	vort_path = joinpath( toplevel,"mat_file" , panelcase)
	sav_path = joinpath( toplevel, "old_results", panelcase )
	local_sav_path = "" # for temporary data
	return vort_path, sav_path,local_sav_path
end;

# ╔═╡ 4abde889-f80d-431c-9a78-4a53d70f4727
function markos_path(panelcase)
	toplevel = raw"/Users/marko/Library/CloudStorage/GoogleDrive-mbudisic@clarkson.edu/.shortcut-targets-by-id/1U-9WSU_a1YjWMmjCKhqZLiC6Rha4kesp/Yiran_Alemni/will"
	
	vort_path = joinpath(toplevel,"data",panelcase)
	sav_path = joinpath(toplevel,"results",panelcase)
	local_sav_path = "/Users/marko/Downloads" # for temporary data
	return vort_path, sav_path, local_sav_path
end;

# ╔═╡ 21eb85dc-e4d8-4fde-b363-2e604d419cd2
function melissas_path(panelcase)
	toplevel = raw"EDITHERE/GreenYiran/will"
	
	vort_path = joinpath(toplevel,"data",panelcase)
	sav_path = joinpath(toplevel,"results",panelcase)
	local_sav_path = "" # for temporary data	
	return vort_path, sav_path, local_sav_path
end;

# ╔═╡ c9a3b116-429a-4937-a0fc-a70fbd0a32ed
begin
	vort_path, sav_path, local_path = alemnis_path(panelcase)

	if !( isdir(vort_path) && isdir(sav_path) )
		vort_path, sav_path, local_path = markos_path(panelcase)
	end

	if !( isdir(vort_path) && isdir(sav_path) )
		vort_path, sav_path, local_path = melissas_path(panelcase)
	end
	

	if !( isdir(vort_path) && isdir(sav_path) )
		error("Unsuccessful path change -- folders don't exist")
	end

	nsnapshots = length(readdir(vort_path))

	@show vort_path
	@show sav_path
end;

# ╔═╡ 585327c7-63b5-4197-ae66-4c90f09fbb6a
md"""
# Retrieve all snapshots and compute their PDs.
"""

# ╔═╡ 56bd1c69-2d1e-4cd6-9603-7d986512f215
md"""
# Visualize a single snapshot
"""

# ╔═╡ e3d69201-3c69-4835-bc81-9c46ed86d8cf
md"""
Tune the following values:
  - Autoplay snapshots $(@bind autoplay PlutoUI.CheckBox(default=false))
  - Topological noise cutoff $(@bind cut PlutoUI.Slider(0:0.01:10, show_value = true, default=0.5))
  - Show H0 reps.? $(@bind showH0 CheckBox(default=true))
  - Show H1 reps.? $(@bind showH1 CheckBox(default=true))

- Saving? $(@bind issaving CheckBox(default=false))
- Extension: $(@bind ext Select(["png","pdf"]))
"""

# ╔═╡ 61878364-e6b4-4886-bd45-eaa26863f363
md"""
## Compute the persistent homology.

"""

# ╔═╡ 630acaf0-4b21-4ed7-893f-7eaf6ade2403
md"""
## Extract the representatives

A persistence diagram PD at a particular order $H_n$ is an array of `PersistenceDiagrams.PersistenceInterval`-typed objects.

Each `PersistenceInterval` has properties:
`(:birth, :death, :birth_simplex, :death_simplex, :representative)`

Given a `PersistenceInterval`, `PI`, the representative `PI.representative` is a vector of Ripserer.Cubes or a Ripserer.Chain.

Calling `vertices()` on each element of PI.representative (syntax `.()` applies a function elementwise) returns a tuple of CartesianIndex (H0) or CartesianIndex pairs (H1) that index into the original field analyzed by PD.

"""


# ╔═╡ 60e39f80-ac6e-4dfe-8a99-e549f58b414c


# ╔═╡ a975d268-2f5e-4d50-8cae-49eb0d4654d5
md"""
### $H_0$ representatives
"""

# ╔═╡ 9d5a6b96-26a1-4343-8377-6a2e60a4828f
md"""
### $H_1$ representatives
"""

# ╔═╡ 736fdac7-87a4-4268-b8ff-34a57a45c1ce


# ╔═╡ 17e025b4-d03f-40c4-8096-f7dccf5926ef
md"""
Visualize H1 representatives. 

Remember `.(...)` syntax broadcasts (vectorizes) the function along the vector argument.


"""

# ╔═╡ d3a963e8-9508-4a93-8c49-5013af4c9ff1
md"""
## PlotAll
"""

# ╔═╡ 116787f6-a4d9-48c8-8b2f-fb75a434ef1d
md"""
# Plot Persistence Diagram

Flipping the axes in PD is implemented by creating a deep copy of `PersistenceDiagram` object, in which all its `PersistenceIntervals` have swapped birth/death or sign of birth/death changed or both.

Then a plotting function simply invokes the usual PD plotter on each of them, and changes their labels/axes so that it's disambiguated.

It's not clear to me which one we should use, so I left it as option-driven so we can try things out. We probably need to check on some imaginary function what should work.

I think when plotting "persistence" on y axis, we want "Swap axes" but not "Flip sign".
When plotting "death" on y axis, we want "Flip sign" on, but "Swap axes" off?
"""

# ╔═╡ 9c867fb4-f2a4-481d-add0-5230b220e14e
md"""
 Swap axes $(@bind axswap CheckBox(default=false))
 Flip sign $(@bind sgnflip CheckBox(default=true))
 Plot style $(@bind PDplotStyle Select(
			 ["persistence", "death"],default="death"))
"""

# ╔═╡ 3f83c58a-dd59-4194-a5ee-ea8bfc101cdd


# ╔═╡ 8825772f-ca29-4457-a281-39d53f1794e0
md"""
# Computing distances

Produce traces : $(@bind doDistanceTraces CheckBox(default=true))
"""

# ╔═╡ 32fb226a-cbe0-4ca6-b495-66c189238807
md"""
- Use peak $(@bind peakD Select(["Wasserstein","Bottleneck"],default="Wasserstein")) distance instead? $(@bind usepeak CheckBox(default=true))
"""

# ╔═╡ e2b8fd8b-5415-4ae0-94cc-64286f23813d
md"""
- Wasserstein distance order $(@bind Wq PlutoUI.Slider(1:2,default=2,show_value=true))
- Topological cutoff for comparison $(@bind comp_cut PlutoUI.Slider(0:0.01:20, default=1, show_value=true))
"""

# ╔═╡ 28a1a684-7156-46c2-9351-94741a710752


# ╔═╡ 823da704-1281-428a-9c30-f70807bf56bf
"""
	pair_op computes a pair operation (e.g. a distance) between skip-separated elements of the vector, by sliding the skip window along it
"""
function pair_op( op, v; skip=1 )
	
	return [ op(a,b) for (a,b) in zip(v[1:end-skip], v[1+skip:end]) ] 
end

# ╔═╡ 14a43458-3962-4ca0-abaf-938db2f32c5a
"""
Compute the distance dtype between two persistent diagrams.
Supported dtype = Bottleneck() or Wasserstein()
"""
function distance( PH_A, PH_B; dtype=Wasserstein())
	return dtype(PH_A, PH_B; matching=false)
end

# ╔═╡ 5535b772-62e5-46ff-972d-945bdea199be
function distance_time_traces( tt, snapshots, skip=1 )
	PHpos = getindex.(snapshots, (:PHpos) )
	PHneg = getindex.(snapshots, (:PHneg) )

	ff(ss, dd) = pair_op( (x,y) -> distance(x,y; dtype=dd), ss; skip=skip )

	out = DataFrame(
		t = collect( tt[1:end-1] ),
		POS_W = ff(PHpos, Wasserstein(Wq) ),
		POS_B = ff(PHpos, Bottleneck() ),
		NEG_W = ff(PHneg, Wasserstein(Wq) ),
		NEG_B = ff(PHneg, Bottleneck() )
	)
	out[!, "W"] = (out.POS_W .^ Wq + out.NEG_W .^ Wq ) .^ (1/Wq)
	out[!, "B"] = max.(out.POS_B, out.NEG_B )

	colmetadata!(out,:t, "label","Timestep", style=:note)
	colmetadata!(out,:POS_W, "label","Subl. Wass.-$(Wq)", style=:note)
	colmetadata!(out,:NEG_W, "label","Superl. Wass.-$(Wq)", style=:note)
	colmetadata!(out,:W, "label","Total Wass.-$(Wq)", style=:note)
	colmetadata!(out,:POS_B, "label","Subl. Bottlen.", style=:note)
	colmetadata!(out,:NEG_B, "label","Superl. Bottlen.", style=:note)
	colmetadata!(out,:B, "label","Total Bottlen.", style=:note)
	
	return out 

end;

# ╔═╡ 5d5090ae-8083-40d1-8ac0-38a2f9555733
md"""
# Saving files
"""

# ╔═╡ bdd1e568-3770-4931-b283-4841b1916e14
md"""
# Utility functions
"""

# ╔═╡ 7b157ef8-eb23-44b8-aed8-3c3673ab072e
"""
Switches between a PlotUI.Slider and PlotUI.Clock as a way of making a selection.

"""
function snapshotselectorUI(sel,N=nsnapshots)
	if sel
		return PlutoUI.Clock(interval=1,max_value = N,start_running=true)
	else
		return PlutoUI.Slider(1:N, show_value=true)
	end
end

# ╔═╡ 0d90f747-5130-4aa1-9b62-1267065fd5bc
md"""
## Snapshot selection: 

- Snapshot: $(@bind j snapshotselectorUI(autoplay))
- Pad value: $(@bind padding Select([-Inf,0,Inf],default=Inf))
"""

# ╔═╡ fed78c33-26a7-4400-854f-381be309fb0d
"""
Fetch the X,Y,vorticity from the stored files.
"""
function retrieve_snapshot( idx, panel_n )
	#cd(vort_path)
	matvars = matread(joinpath( vort_path, readdir(vort_path)[idx] ))
	vorticity = transpose(matvars["Omega_z_PA"][leftcut[panel_n]:end-2,5:end-4])
	X = matvars["X_Mat"][leftcut[panel_n]:end-2,1] / panelc[panel_n]
	Y = matvars["Y_Mat"][1,5:end-4] / panelc[panel_n]
	return X,Y, Matrix(vorticity) # otherwise transpose is passed and this can create issues 
end

# ╔═╡ 8a3b3829-8756-44d8-b569-9f0ecc9a63ce
"""
Retrieve the coordinate grid, and compute PDs for a particular snapshot

"""
function snapshot_and_PD(snapshot_idx, snapshot_panel; cutoff=0.0,pad=Inf)
	X,Y,vorticity = retrieve_snapshot(snapshot_idx, snapshot_panel)
	Xx, Yy = VortexTDA.pad_grid(X,Y)
	XY = ndgrid(Yy, Xx)
	vort_pos = VortexTDA.pad_field_by_value(vorticity; value=pad)	
	vort_neg = VortexTDA.pad_field_by_value(-vorticity; value=pad)		
	vort_0 = VortexTDA.pad_field_by_value(vorticity; value=0)			
	PH_pos, PH_neg = VortexTDA.cubicalhomology.( (vort_pos, vort_neg);cutoff=cutoff);
	return Dict( 
		[:PHpos, :PHneg, :XY, :vort_pos, :vort_neg, :vort_0] .=> 
		[PH_pos, PH_neg, XY, vort_pos, vort_neg, vort_0] 
	)
end

# ╔═╡ f4fe357b-15f4-46b6-8777-89fda5179603
begin
	t = 1:nsnapshots;
	
	# extract snapshots
	snapshots = snapshot_and_PD.(t, (panel); cutoff=comp_cut, pad=padding);

end;

# ╔═╡ 54d9b89f-f4a2-4508-b590-48bda81e6036
if doDistanceTraces
	# retrieve all PHpos for snapshots
	PHpos = getindex.(snapshots, (:PHpos) )
	PHneg = getindex.(snapshots, (:PHneg) )
end;

# ╔═╡ 51bcc13d-ea96-4a38-9246-c32f27fb46d7
snapshots_pair_distances = distance_time_traces(t,snapshots);

# ╔═╡ 4363a81d-6a48-421d-83fa-096d6f54afc8
if doDistanceTraces
	peakdifference = findmax(peakD == "Wasserstein" ? 
	snapshots_pair_distances.W : 
	snapshots_pair_distances.B)[2]
end;

# ╔═╡ 72f30f80-e20a-4b70-af17-967b52daf023
md"""
### Peak distance and trace comparison

Let's compare neighboring traces:
- Left = $(@bind left_trace PlutoUI.Slider(1:nsnapshots-1,default=peakdifference,show_value=true) )
"""

# ╔═╡ 12c522ed-788c-43e7-9046-d357fc28a4be
if doDistanceTraces
	left = usepeak ? peakdifference : left_trace
end;

# ╔═╡ a4e5c8c4-2af8-4368-94e7-ddbfb13936b5
if doDistanceTraces
	ptrace = plot( Matrix( snapshots_pair_distances[:,2:end] ),
		labels=permutedims(
			colmetadata.( (snapshots_pair_distances,), 
				names(snapshots_pair_distances)[2:end], ("label",) 
		)		),
		color=[:red :orange :blue :green :purple :brown ],
		linewidth=[2 2 2 2 4 4],
		plot_title = "Pairwise topological distance", legend=:outertopright)
	vline!(ptrace,[left], label="Snapshot Comp.",linestyle=:dashdot, linewidth=2,color=:black)
end

# ╔═╡ eb15fcab-4261-48ad-88d2-b102a64785f3
begin
sshot = snapshot_and_PD(j, panel; cutoff=cut,pad=padding);
PH_pos, PH_neg, XY, vort_0 = (
	sshot[:PHpos], 
	sshot[:PHneg], 
	sshot[:XY],
	sshot[:vort_0]
) # extract the outputs into individual variables, for simplicity
end;

# ╔═╡ 9893d996-6b09-4bc1-b262-65ac4921cde9
P = persistence.( PH_pos[2] )

# ╔═╡ f46a5607-0786-4608-8c0c-9714d79211b6
most_persistent_feature_index = findmax(P)[2]

# ╔═╡ f4fe7ed4-b213-4434-8b7c-6bb6d4b17698
PH_pos[2][most_persistent_feature_index]

# ╔═╡ b7985340-2a1c-4fae-9628-123f74d6fe9e
begin
	plot_title = "Panel $(panel) - $(caselabel): snapshot = $(j)/$(nsnapshots)"
	plot_handle = VortexTDA.display_vorticity(XY,vort_0; title=plot_title)
end

# ╔═╡ c7d3c4b5-6b60-4ed1-a9c5-c2c7927adcec
if showH0
	println("Snapshot $j H0 visualized")
	neg_reps0 = VortexTDA.getH0representativePoint.(PH_neg[1])
	pos_reps0 = VortexTDA.getH0representativePoint.(PH_pos[1])

	local x1 =  persistence.(PH_pos[1]) 
	isfin(xx) = .~(isinf.(xx))
	finite(xx) = xx[isfin(xx)]
	normalize(xx) = 
		(xx .- minimum(finite(xx))) ./ 
		(maximum(finite(xx)) .- minimum(finite(xx)))  
	

	
	VortexTDA.plotH0representativePoint!(pos_reps0, plot_handle, XY; 
	markercolor=:magenta,
	markerstrokecolor=:black,markerstrokewidth=2,
	markerstrokealpha=1.0,	
	markeralpha = normalize( persistence.(PH_pos[1])),
	)
	VortexTDA.plotH0representativePoint!(neg_reps0, plot_handle, XY; 
	markercolor=:green, markerstrokecolor=:black,
	markerstrokealpha=1.0,
	markeralpha = normalize( persistence.(PH_neg[1]) ) 
	)

	plot_handle
end

# ╔═╡ 53de07d6-044c-42fd-8dcf-aeaaaf05d5d9
# modifies plot_handle to visualize representatives of positive and negative H1
if showH1
	neg_reps1 = VortexTDA.getH1representativeVector.(PH_neg[2])
	pos_reps1 = VortexTDA.getH1representativeVector.(PH_pos[2])
	@show isa.(neg_reps1, VortexTDA.H1representativeVector )
	VortexTDA.plotH1representativeVector!.(pos_reps1, [plot_handle], [XY];color=:green,linewidth=2)
	
	VortexTDA.plotH1representativeVector!.(neg_reps1, [plot_handle], [XY];color=:magenta,linewidth=2)
	plot_handle
end

# ╔═╡ 9714864a-1172-4331-8d70-a92baf41b950
"""
Plot everything one needs for a snapshot.
"""
function plotall( snapshot;
	plot_title = "Panel $(panel) - $(caselabel) : snapshot = $(j)/$(nsnapshots)",
	H0 = showH0, H1=showH1, kwargs... )

	#### PLOTTING REPRESENTATIVES
	PH_neg = snapshot[:PHneg]
	PH_pos = snapshot[:PHpos]

	# background - 
	plot_handle = VortexTDA.display_vorticity(snapshot[:XY],snapshot[:vort_0];
	c = palette([:blue,:white,:red],128),fill=false,kwargs...);

	pct = 0.5# minimum alpha percentage

	isfin(xx) = .~(isinf.(xx))
	finite(xx) = xx[isfin(xx)]
	function normalize(xx) 
		if isempty(xx) || isempty(finite(xx))
			return xx
		else
		(xx .- minimum(finite(xx))) ./ 
		(maximum(finite(xx)) .- minimum(finite(xx))) .* (1-pct) .+ pct
		end
	end

	if H0
	neg_reps0 = VortexTDA.getH0representativePoint.(PH_neg[1])
	pos_reps0 = VortexTDA.getH0representativePoint.(PH_pos[1])

	pos_alpha = normalize(persistence.(PH_pos[1]))
	neg_alpha = normalize(persistence.(PH_neg[1]))
		
		
	VortexTDA.plotH0representativePoint!(pos_reps0, plot_handle, XY,markercolor=:blue, marker=:circle,
	alpha=pos_alpha,markersize=6)
	VortexTDA.plotH0representativePoint!(neg_reps0, plot_handle, XY, markercolor=:green, marker=:square,
	alpha=neg_alpha,markersize=6)
	end

	if H1
		neg_reps1 = VortexTDA.getH1representativeVector.(PH_neg[2])
		pos_reps1 = VortexTDA.getH1representativeVector.(PH_pos[2])

		pos_alpha = normalize(persistence.(PH_pos[2]))
		neg_alpha = normalize(persistence.(PH_neg[2]))
		
	
		for (rep1, pers) in zip( pos_reps1, pos_alpha )
			VortexTDA.plotH1representativeVector!(rep1, plot_handle, XY; color=:red,linewidth=4,alpha=pers)
		end
	
		for (rep1, pers) in zip( neg_reps1, neg_alpha )
			VortexTDA.plotH1representativeVector!(rep1, plot_handle, XY; color=:orange,linewidth=4,alpha=pers)
		end
		
	end

	### PLOTTING PD
	pd_handle = VortexTDA.plotPDs( PH_pos, PH_neg; 
		xlims=(-60,60),ylims=(-60,60),
		persistence= (PDplotStyle == "persistence"), infinity=50,legend=:outertopright)

	return plot_handle, pd_handle

end

# ╔═╡ 4224e4f8-6613-42b5-8ad5-23278f4caa21
begin
	field, PD = plotall( snapshots[j];
	plot_title = "Panel $(panel) - $(caselabel) : snapshot = $(j)/$(nsnapshots)",
	H0 = showH0, H1=showH1 )
	plot(field, PD, layout=@layout [a;b] )
end


# ╔═╡ 84285ce0-9f49-4f75-be84-2125a35b5e75
if doDistanceTraces
	l = @layout [a; b c; d e]
	P1,D1 = plotall( snapshots[left], plot_title="S = $(left)/$(nsnapshots)",H0 = showH0, H1=showH1 )
	P2,D2 = plotall( snapshots[left+1], plot_title="S = $(left+1)/$(nsnapshots)",H0 = showH0, H1=showH1 )
	comparison_plot = plot(ptrace,P1,P2,D1,D2, layout=l,size=(1200,1024),
		plot_title = "Panel $(panel) - $(caselabel) - tcut = $(comp_cut)")
end

# ╔═╡ 3e859ca2-e53a-4713-a374-44df73b5a485
plot_PD_handle = VortexTDA.plotPDs(PH_pos, PH_neg; xlims=(-60,60),ylims=(-60,60),
						title=plot_title, persistence= (PDplotStyle == "persistence"),
						neg_swap_axes = axswap, neg_flip_sign = sgnflip )

# ╔═╡ 7f5c642e-ebf2-4992-84f6-cfe169913fe4
if issaving 
	coredesc = "$(caselabel)_$(panelcase)"
	snapshotfile = "snapshot_$(coredesc)_$(@sprintf("%02d", j)).$(ext)"
	xlsfile = "$(coredesc)_distances.xlsx"
	PDfile = "pd_$(coredesc)_$(@sprintf("%02d", j)).$(ext)"
	compfile = "comp_$(coredesc)_$(@sprintf("%02d", left)).$(ext)"

	savefig( plot_handle,joinpath(local_path,snapshotfile)),
	savefig( plot_PD_handle,joinpath(local_path,PDfile)),
	savefig( comparison_plot,joinpath(local_path,compfile))

	XLSX.writetable(joinpath(local_path,xlsfile), snapshots_pair_distances, overwrite=true)

end

# ╔═╡ c0ed185e-bf85-4145-bf9d-dfe34b8dc143
md"""
# Vorticity level sets

ε = $(@bind ε Slider(-15:1:15, show_value=true))

"""

# ╔═╡ b635a4db-ef3a-4817-a05e-10ca778a3d72
begin
	local l = @layout [a b; d e]
#	S1 = plotall(snapshots[j];colorbar=false)[1];
	S1 = display_vorticity(XY,snapshots[j][:vort_0] ;
	fill=false, c=:balance,interpolate=false, title = L"\omega (x,y)");

	
	
	L1 = display_vorticity(XY,snapshots[j][:vort_0] .< ε ;
	fill=false, interpolate=false, title = L"\omega (x,y) < \varepsilon = %$(ε)",
	colorbar=false, c = palette([:white, :gray], 2),clim=:auto);


	B1 = barcode(PH_pos; xlims=(-20,20),title="Sublevel sets",xlabel=L"\omega",linewidth=6)
	vline!(B1,[1]; linewidth=3,color=:gray,linestyle=:dash,label=L"$\varepsilon$")
	vline!(B1,[12]; linewidth=3,color=:gray,linestyle=:dash,label=L"$\varepsilon$")
	
	B2 = barcode(PH_neg; xlims=(-20,20),linewidth=6,title="Superlevel sets",xlabel=L"\omega",xflip=true,xticks=((-20,-10,0,10,20), (20,10,0,-10,-20)))
	vline!(B2,[-1]; linewidth=3, color=:gray,linestyle=:dash,label=L"$\varepsilon$")
	vline!(B2,[-12]; linewidth=3, color=:gray,linestyle=:dash,label=L"$\varepsilon$")

	
	levelset_handle = plot(S1, L1,B1, B2; layout=l,interpolate=false,size=(1200,600),dpi=300)
end



# ╔═╡ 66a8b56e-d180-4b3a-85f0-c51eb8adf61f
Sgen = plotall(snapshots[j];colorbar=false,fill=false, c=:balance,interpolate=false,plot_title="")[1]


# ╔═╡ 3e13e570-82ee-4153-a5a8-a7aab161913f
md"""
# Barcode
"""

# ╔═╡ b9f2be3e-7ea5-4868-afde-d63ef87c3fd4
begin
	bar0 = barcode(PH_pos[1]; linewidth=6,marker=:o)
	bar1 = barcode(PH_pos[2]; linewidth=6,marker=:v)
	pd_bar = plot(bar0)
	plot!(pd_bar,bar1)
end


# ╔═╡ bd715a7e-1220-428f-b5d9-822345864cee
	pd_handle = VortexTDA.plotPDs( PH_pos, PH_neg;
		xlims=(-30,30),ylims=(-30,30),
		persistence=false, infinity=25,legend=:bottomleft)


# ╔═╡ 662ad30c-7d2c-4c5b-b48d-63e9222e7b07
if issaving
	local levelsetfile = "levelset_$(coredesc)_$(@sprintf("%02d", j)).$(ext)"
	savefig(S1,joinpath(local_path,levelsetfile))

	local repsfile = "levelset_$(coredesc)_$(@sprintf("%02d", j))_reps.$(ext)"
	savefig(Sgen,joinpath(local_path,repsfile))

	local phfile = "levelset_$(coredesc)_$(@sprintf("%02d", j))_PD.$(ext)"
	savefig(pd_handle,joinpath(local_path,phfile))
	
	for (idx,v) in zip( ["lvl","b_sub","b_sup"], [L1,B1,B2] ) 
		epsfile = "levelset_$(coredesc)_$(@sprintf("%02d", j))_eps_$(ε)_$(idx).$(ext)"
		savefig( v,joinpath(local_path,epsfile))
	end
end

# ╔═╡ Cell order:
# ╠═43e81d74-37d8-4574-b06e-a57be04fe6be
# ╠═032b2c0f-0c52-49dd-840d-65caa3ae7b9b
# ╠═4684f0f4-1fb0-4248-a6c8-3d129ebe6725
# ╠═4d206232-f1e6-11ec-039a-776b65cfce0a
# ╠═d17bfc41-9551-4b0b-b643-8a955fb492a0
# ╠═4bef167e-d811-4832-8646-3039409e012d
# ╠═f7b9ed63-b559-4155-8389-dad59c66a5d1
# ╟─f4f66a74-5a05-498a-b3db-b7973241429f
# ╟─a0c3e1b9-e996-45c1-b84a-70dd5ebba63a
# ╠═523b6671-00c3-45c8-92ba-f8540829dcd7
# ╠═1c880145-d1d0-420b-af3f-f6a79d8d8e7c
# ╟─fe829fc7-0b0e-43e9-87a4-bc69d1f48fa0
# ╠═c9a3b116-429a-4937-a0fc-a70fbd0a32ed
# ╠═f6641248-3519-4c0f-b02b-a2e8343a9c6e
# ╠═4abde889-f80d-431c-9a78-4a53d70f4727
# ╠═21eb85dc-e4d8-4fde-b363-2e604d419cd2
# ╟─585327c7-63b5-4197-ae66-4c90f09fbb6a
# ╠═f4fe357b-15f4-46b6-8777-89fda5179603
# ╟─56bd1c69-2d1e-4cd6-9603-7d986512f215
# ╠═e3d69201-3c69-4835-bc81-9c46ed86d8cf
# ╠═0d90f747-5130-4aa1-9b62-1267065fd5bc
# ╠═4224e4f8-6613-42b5-8ad5-23278f4caa21
# ╠═eb15fcab-4261-48ad-88d2-b102a64785f3
# ╠═9893d996-6b09-4bc1-b262-65ac4921cde9
# ╠═f46a5607-0786-4608-8c0c-9714d79211b6
# ╠═f4fe7ed4-b213-4434-8b7c-6bb6d4b17698
# ╠═8a3b3829-8756-44d8-b569-9f0ecc9a63ce
# ╠═b7985340-2a1c-4fae-9628-123f74d6fe9e
# ╟─61878364-e6b4-4886-bd45-eaa26863f363
# ╟─630acaf0-4b21-4ed7-893f-7eaf6ade2403
# ╠═60e39f80-ac6e-4dfe-8a99-e549f58b414c
# ╟─a975d268-2f5e-4d50-8cae-49eb0d4654d5
# ╠═c7d3c4b5-6b60-4ed1-a9c5-c2c7927adcec
# ╟─9d5a6b96-26a1-4343-8377-6a2e60a4828f
# ╠═53de07d6-044c-42fd-8dcf-aeaaaf05d5d9
# ╠═736fdac7-87a4-4268-b8ff-34a57a45c1ce
# ╟─17e025b4-d03f-40c4-8096-f7dccf5926ef
# ╟─d3a963e8-9508-4a93-8c49-5013af4c9ff1
# ╠═9714864a-1172-4331-8d70-a92baf41b950
# ╟─116787f6-a4d9-48c8-8b2f-fb75a434ef1d
# ╟─9c867fb4-f2a4-481d-add0-5230b220e14e
# ╠═3e859ca2-e53a-4713-a374-44df73b5a485
# ╠═3f83c58a-dd59-4194-a5ee-ea8bfc101cdd
# ╟─8825772f-ca29-4457-a281-39d53f1794e0
# ╠═54d9b89f-f4a2-4508-b590-48bda81e6036
# ╠═51bcc13d-ea96-4a38-9246-c32f27fb46d7
# ╠═a4e5c8c4-2af8-4368-94e7-ddbfb13936b5
# ╟─72f30f80-e20a-4b70-af17-967b52daf023
# ╟─32fb226a-cbe0-4ca6-b495-66c189238807
# ╠═4363a81d-6a48-421d-83fa-096d6f54afc8
# ╠═12c522ed-788c-43e7-9046-d357fc28a4be
# ╠═e2b8fd8b-5415-4ae0-94cc-64286f23813d
# ╠═84285ce0-9f49-4f75-be84-2125a35b5e75
# ╠═5535b772-62e5-46ff-972d-945bdea199be
# ╠═28a1a684-7156-46c2-9351-94741a710752
# ╠═823da704-1281-428a-9c30-f70807bf56bf
# ╠═14a43458-3962-4ca0-abaf-938db2f32c5a
# ╟─5d5090ae-8083-40d1-8ac0-38a2f9555733
# ╠═7f5c642e-ebf2-4992-84f6-cfe169913fe4
# ╟─bdd1e568-3770-4931-b283-4841b1916e14
# ╠═7b157ef8-eb23-44b8-aed8-3c3673ab072e
# ╠═fed78c33-26a7-4400-854f-381be309fb0d
# ╠═c0ed185e-bf85-4145-bf9d-dfe34b8dc143
# ╠═b635a4db-ef3a-4817-a05e-10ca778a3d72
# ╠═66a8b56e-d180-4b3a-85f0-c51eb8adf61f
# ╠═662ad30c-7d2c-4c5b-b48d-63e9222e7b07
# ╠═3e13e570-82ee-4153-a5a8-a7aab161913f
# ╠═b9f2be3e-7ea5-4868-afde-d63ef87c3fd4
# ╠═bd715a7e-1220-428f-b5d9-822345864cee
