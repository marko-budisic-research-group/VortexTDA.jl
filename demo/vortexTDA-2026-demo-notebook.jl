### A Pluto.jl notebook ###
# v1.0.3

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 80e280bc-58e9-4822-a114-df50fda303cb
begin
	using Pkg
#	Pkg.add(url="https://github.com/marko-budisic-research-group/VortexTDA.jl")
end

# ╔═╡ a1543d3e-d04d-4a5e-861b-51c3dd8ae77f
begin
	Pkg.develop("VortexTDA")
end

# ╔═╡ 75e36201-d78e-4f49-b99b-b6d52ecaa8e7
begin
	using MAT
	using PersistenceDiagrams
	using LaTeXStrings
	using DelimitedFiles
	using JLD2
	using Printf
	using LazyGrids
	using XLSX
	using DataFrames
	using Revise
	using Images
	using TikzPictures
	using Ripserer
	using Makie
end

# ╔═╡ 9ee55ad0-bdfe-11f1-b929-4fee718319f6
begin
	using PlutoUI
TableOfContents()
end

# ╔═╡ c89238ca-bbb6-45a5-9c5e-708656653b31
import VortexTDA

# ╔═╡ 2804165e-d241-493d-8222-7f0486e695ef
md"""
# Initial Setup
"""

# ╔═╡ b3dce772-d171-4f1e-a323-3c82a08a031b
md"""
## Panel parameters
  - Panel $(@bind panel confirm(PlutoUI.Slider(1:5,default=3, show_value=true)))
  - θ $(@bind ALPHA confirm(Select([:5,:10,:15,:20,:25],default=:15)))
"""

# ╔═╡ 6f12600d-b72c-439f-9f5b-fee07bba38e3
begin
	PhiToFile = Dict(
		:5 => 5,
		:10 => 10,
		:15 => 15,
		:20 => 20,
		:25 => 25
	)
	clevel = 15
	panelc = [0.0274 0.0393 0.0505 0.0617 0.0736]; 
	#panelc = (c) chord length (in meters) per case
	leftcut = [5 13 21 28 36]
	#leftcut = row/column to shift PIV coord to T.E. of panels
	# [5 13 21 28 37]
	panelcase = "Panel_$(panel)"
	phicase = "$(PhiToFile[ALPHA])_Deg_Pitch_Amp"

end

# ╔═╡ 7fd642aa-bdf9-4141-acb2-edf9f704ffe8
md"""
## Paths
"""

# ╔═╡ 19925c2b-b726-4482-ac66-e31748d08d6d
@bind toplevel_string confirm(PlutoUI.TextField((90,1), default="R:\\a-magreen\\Yiran_Alemni\\Research\\TDA\\King_Justin_Thesis_Data\\"))

# ╔═╡ ebc5fe9b-88f5-4c1b-b84a-134604f4867e
toplevel = toplevel_string

# ╔═╡ a956645f-859e-457c-83b7-cbe40e6db874
@bind vort_path_string confirm(PlutoUI.TextField((90,1), default="raw_data"))

# ╔═╡ fbbb4907-7ed7-4e9d-b1bb-b43fda7c285b
vort_path = joinpath( toplevel, vort_path_string, panelcase,phicase,"Phase_Averaged")

# ╔═╡ 39fb4f4d-9e44-4aa8-b92b-9e6e32445e3c
@bind toplevel_string_vID confirm(PlutoUI.TextField((90,1), default="R:\\a-magreen\\Yiran_Alemni\\Research\\TDA\\King_Justin_Thesis_Data\\vortexID_methods\\"))

# ╔═╡ e13eb806-a69d-4e31-acd1-78099355d0f8
toplevel_vID = toplevel_string_vID

# ╔═╡ 4e83703d-3246-4568-ad0f-90e3491bd00b
@bind vortID_path_string confirm(PlutoUI.TextField((90,1), default="raw_data"))

# ╔═╡ 39a71b6e-a534-43e4-96b2-d426426b3195
vortID_path = joinpath(toplevel_vID, vortID_path_string, panelcase,phicase,"Phase_Averaged")

# ╔═╡ 853e9300-2dc6-4694-bd39-51e22bd87709
@bind sav_path_string_vID_a confirm(PlutoUI.TextField((90,1), default="results"))

# ╔═╡ adc991bd-b4cf-4835-b051-d0e2ca0c9877
sav_path_vID_a = joinpath( toplevel_vID, sav_path_string_vID_a, panelcase,phicase,"Phase_Averaged","idMethod_Types")

# ╔═╡ 7be1c9b8-cbe7-499c-93ba-93ac4a65269a
@bind local_sav_path_string confirm(PlutoUI.TextField((90,1), default="C:\\Users\\yiran\\Downloads"))

# ╔═╡ 69de7bde-7238-478a-8e8a-283920978843
md"""
# Vortex iD Method Selection
- iD Method: $(@bind idType confirm(Select([:Vorticity,:Q_Characteristic,:Truesdell_No,:Omega_Rortex,:Lambda_2,:Delta_Discriminant,:Lambda_ci,:Rortex,:R_Characteristic],default=:Q_Characteristic)))
"""

# ╔═╡ 02b70dc9-da39-4812-9ecc-6848c98a9bbc
sav_path_string_vID_b = joinpath(sav_path_vID_a,"$(idType)")

# ╔═╡ 2cee7e2c-5752-4b93-bc7f-88271396b96a
sav_path_vID_barcodes = joinpath(sav_path_string_vID_b,"barcodePersistence")

# ╔═╡ ea6db877-d78b-49e2-bd92-6ecaf0a40ecc
sav_path_vID_fieldCohomology = joinpath(sav_path_string_vID_b, "fieldCoHomology")

# ╔═╡ 6478dcd0-1b4b-40ab-a88f-33ac3b5132f0
sav_path_vID_fieldHomology = joinpath(sav_path_string_vID_b, "fieldHomology")

# ╔═╡ 07da6088-deb7-4f03-8862-23b10aafe4ad
sav_path_vID_metricSpaces = joinpath(sav_path_string_vID_b)

# ╔═╡ 13430463-2b22-4564-a125-f869cc327ed2
sav_path_vID_persistenceDiagrams = joinpath(sav_path_string_vID_b, "persistenceDiagrams")

# ╔═╡ 36066daa-f451-419b-9b4a-ac452bee63d9
begin
	idMatrix_2Name = Dict(
			:Vorticity => "Omega_z_PA",
			:Q_Characteristic => "Q_Characteristic",
			:Truesdell_No => "Truesdell_Number",
			:Omega_Rortex => "Omega_Rortex",
			:Lambda_2 => "Lambda_2",
			:Delta_Discriminant => "Discriminant_deprCubic",
			:Lambda_ci => "Lambda_ci_mag",
			:Rortex => "Rortex",
			:R_Characteristic => "R_Characteristic"
		)
	
		idMatrixcase = "$(idMatrix_2Name[idType])"
end

# ╔═╡ 5ee9618c-dab6-472e-b187-bfd5b77bd4d1
begin
	idTypeToFile = Dict(
		:Vorticity => "Vorticity",
		:Q_Characteristic => "Q Characterstic",
		:Truesdell_No => "Truesdell Number",
		:Omega_Rortex => "Omega Rortex",
		:Lambda_2 => "Lambda 2",
		:Delta_Discriminant => "Discriminant",
		:Lambda_ci => "Lambda ci",
		:Rortex => "Rortex",
		:R_Characteristic => "R Characteristic"
	)

	idMethodcase = "$(idTypeToFile[idType])"

end

# ╔═╡ 1fabc218-b585-4854-aad2-4295e702326d
begin
	if idType == :Vorticity
		cutoffType = :cut_vorticity
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
	elseif idType == :Q_Characteristic
		cutoffType = :cut_Q 
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
	elseif idType == :Truesdell_No
		cutoffType = :cut_Truesdell
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
	elseif idType == :Omega_Rortex
		cutoffType = :cut_OmegaR
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
	elseif idType == :Lambda_2
		cutoffType = :cut_Lambda2
		sublevel_H0 = true
		superlevel_H0 = false
		sublevel_H1 = false
		superlevel_H1 = true
	elseif idType == :Delta_Discriminant
		cutoffType = :cut_Delta
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
	elseif idType == :Lambda_ci
		cutoffType = :cut_LambdaCi
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
	elseif idType == :Rortex
		cutoffType = :cut_Rortex
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
	elseif idType == :R_Characteristic
		cutoffType = :cut_R
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
	else 
		cutoffType = 0
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
	end
	
	idCutoff_2Var = Dict(
		:cut_vorticity => 5.00,
		:cut_Q => 20.00,
		:cut_Truesdell => 0.95, 
		:cut_OmegaR => 0.45, 
		:cut_Lambda2 => 125.00,
		:cut_Delta => 1e3,
		:cut_LambdaCi => 20.00,
		:cut_Rortex => 7.00,
		:cut_R => 25.00
	)

	idCutoffcase = idCutoff_2Var[cutoffType]
	levelsetH0Case = (sublevel_H0,superlevel_H0)
	levelsetH1Case = (sublevel_H1,superlevel_H1)
end

# ╔═╡ 76cc90e9-b276-4ac1-968e-fb502dc124d1
begin
	if idType == :Vorticity
		rangeVar = :range_vorticity
	elseif idType == :Q_Characteristic
		rangeVar = :range_Q 
	elseif idType == :Truesdell_No
		rangeVar = :range_Truesdell
	elseif idType == :Omega_Rortex
		rangeVar = :range_OmegaR
	elseif idType == :Lambda_2
		rangeVar = :range_Lambda2
	elseif idType == :Delta_Discriminant
		rangeVar = :range_Delta
	elseif idType == :Lambda_ci
		rangeVar = :range_LambdaCi
	elseif idType == :Rortex
		rangeVar = :range_Rortex
	elseif idType == :R_Characteristic
		rangeVar = :range_R
	else 
		rangeVar = 0
	end
	
	# idRange_2Var = Dict(
	# 	:range_vorticity => [(axesLims_minus-5),(axesLims_plus+5)],
	# 	:range_Q => [(axesLims_minus-5),(axesLims_plus+5)],
	# 	:range_Truesdell => [(axesLims_minus-5),(axesLims_plus+5)], 
	# 	:range_OmegaR => [0,1.05], 
	# 	:range_Lambda2 => [(axesLims_minus-5),(axesLims_plus+5)],
	# 	:range_Delta => [(axesLims_minus-5),(axesLims_plus+5)],
	# 	:range_LambdaCi => [(axesLims_minus-5),(axesLims_plus+5)],
	# 	:range_Rortex => [(axesLims_minus-5),(axesLims_plus+5)],
	# 	:range_R => [(axesLims_minus-5),(axesLims_plus+5)]
	# )

	# idRangecase = idRange_2Var[rangeVar]
end

# ╔═╡ 1f95d157-8138-4013-bd98-c3d5c609c1b7
md"""
# Retrieve all snapshots and compute their PDs.
"""

# ╔═╡ fa982734-9c0e-451d-b834-687ab1f8b198
md"""
 ## Read number of snapshots per case
"""

# ╔═╡ 668b9ef2-c136-47ee-9567-b1e574de9be9
nsnapshots = length(readdir(vortID_path))

# ╔═╡ 5accfb77-237e-4174-bd78-594bdd19e765
md"""
# Visualize a single snapshot
"""

# ╔═╡ d38ef224-0fe2-478b-a107-0a59bb9801c7
md"""
Tune the following values:
  - Autoplay snapshots $(@bind autoplay confirm(PlutoUI.CheckBox(default=false)))
  - Topological noise cutoff $(@bind cut Scrubbable(idCutoffcase))
  - Show H0 reps.? $(@bind showH0 confirm(CheckBox(default=true)))
  - Show H1 reps.? $(@bind showH1 confirm(CheckBox(default=true)))

- Saving? $(@bind issaving confirm(CheckBox(default=true)))
- Extension: $(@bind ext confirm(Select(["svg","png","pdf"])))
- Make Gifs? $(@bind gif_flag confirm(CheckBox(default=false)))
"""

# ╔═╡ c199acb2-81fe-475b-84f6-26f8c1f8138e
"""
Switches between a PlotUI.Slider and PlotUI.Clock as a way of making a selection.

"""
function snapshotselectorUI(sel,N=nsnapshots)
	if sel
		return PlutoUI.Clock(interval=60,max_value = N,start_running=true)
	else
		return PlutoUI.Slider(1:N, show_value=true)
	end
end

# ╔═╡ 04acb461-71ff-4d27-b113-f0dfe37e6080
md"""
## Snapshot selection: 

- Snapshot: $(@bind j (snapshotselectorUI(autoplay)))
- Pad value: $(@bind padding confirm(Select([-Inf,0,Inf,"None"],default=Inf)))
"""

# ╔═╡ 217c1636-fca2-46df-8324-1a233f3f1e4d
"""
Fetch the X,Y,vorticity from the stored files.
"""
function retrieve_snapshot( idx, panel_n, idTypeVar)
	#cd(vort_path)
	matvars = matread(joinpath( vort_path, readdir(vort_path)[idx] ))
	vorticity = transpose(matvars["Omega_z_PA"][leftcut[panel_n]:end-9,3:end-2])
	U = transpose(matvars["U_mat"][leftcut[panel_n]:end-9,3:end-2])
	V = transpose(matvars["V_mat"][leftcut[panel_n]:end-9,3:end-2])
	X = matvars["X_mat"][leftcut[panel_n]:end-9,1] / panelc[panel_n]
	Y = matvars["Y_mat"][1,3:end-2] / panelc[panel_n]

	matvars_vID = matread(joinpath(vortID_path, readdir(vortID_path)[idx] ))


	# "Omega_z_PA","Q_Characteristic", "Truesdell_Number", "Omega_Rortex", "Lambda_2", "Discriminant_deprCubic", "Lambda_ci_mag", "Rortex", "R_Characteristic"


	idType_data = transpose(matvars_vID["$(idTypeVar)"][leftcut[panel_n]:end-9,3:end-2])
	
	return X,Y,U,V,Matrix(idType_data)
end

# ╔═╡ 684e791c-b210-43c6-89ed-ea782a59e6ff
"""
Retrieve the coordinate grid, and compute PDs for a particular snapshot

"""
function snapshot_and_PD(snapshot_idx, snapshot_panel, idTypeVar; cutoff=cut, pad=Inf)


	
	X,Y,U,V,field2D_iD = retrieve_snapshot(snapshot_idx, snapshot_panel, idTypeVar)
	Xx, Yy = VortexTDA.pad_grid(X,Y)
	XY = ndgrid(Yy, Xx)
	
	################################################################
	# 2D Field
	field2D_pos = VortexTDA.pad_field_by_value(field2D_iD; value=pad)	
	field2D_neg = VortexTDA.pad_field_by_value(-field2D_iD; value=pad)		
	field2D_0 = VortexTDA.pad_field_by_value(field2D_iD; value=0)
	################################################################
	U_0 = VortexTDA.pad_field_by_value(U;value=0)
	V_0 = VortexTDA.pad_field_by_value(V;value=0)
	
	field2D_raw = field2D_iD

	################################################################
	# 2D Field Homology
	PH_pos, PH_neg = VortexTDA.cubicalhomology.( (field2D_pos, field2D_neg);cutoff=cutoff);
	################################################################

	################################################################
	# 2D Field (Co)homology
	# #coPH_pos, coPH_neg = cubicalCOhomology.( (field2D_pos, field2D_neg);cutoff=cutoff);
	################################################################
	

	
	return Dict( 
		[:PHpos, :PHneg, :field2D_raw, :field2D_pos, :field2D_neg, :field2D_0, :U_0, :V_0, :XY] .=> [PH_pos, PH_neg, field2D_raw, field2D_pos, field2D_neg, field2D_0, U_0, V_0, XY] 
	)
end

# ╔═╡ ff424e9d-542f-4dff-bd96-9b5b8e14a77b
begin

	# typeof(t) = UnitRange{Int64}
	global t_TDA = 1:nsnapshots;
	
	# extract snapshots
	
	# arguments: takes in (t), (panel), (cut), (padding)
	# returns: (snapshots)
	# length(snapshots) = 24
	# typeof(snapshots) = Vector{Dict{Symbol, Any}} (alias for Array{Dict{Symbol, 	
	# 					  Any}, 1})
	snapshots = snapshot_and_PD.(t_TDA, (panel), (idMatrixcase); cutoff=cut, pad=padding);

end;

# ╔═╡ dc17f5b3-5805-4f2a-8396-267cf7ff97ef
		axesLims_plus_HOLD, axesLims_minus_HOLD, raw_maxs_hold, raw_mins_hold = VortexTDA.universalLims(t_TDA, snapshots)

# ╔═╡ 2c0004e1-b90b-45fc-b84f-6e95d333102c
begin

sshot = snapshot_and_PD(j, panel, idMatrixcase; cutoff=cut,pad=padding);
PH_pos, PH_neg, field2D_raw, field2D_pos, field2D_neg, field2D_0, U_0, V_0, XY = (
	sshot[:PHpos], 
	sshot[:PHneg],
	sshot[:field2D_raw],
	sshot[:field2D_pos],
	sshot[:field2D_neg],
	sshot[:field2D_0],
	sshot[:U_0],
	sshot[:V_0],
	sshot[:XY] 
	)# extract the outputs into individual variables, for simplicity

	# vort_0 = vorticity field; bordered by value of 0
	
end;

# ╔═╡ dc4c2519-e385-493d-bf56-7bf9833f85c5
field2D_pos

# ╔═╡ 650ed927-a7b5-4208-9f0b-6cd6c79149b9
field2D_neg

# ╔═╡ ae234222-fee7-4244-9659-b08d6b025e5a
field2D_0

# ╔═╡ 5a8fb172-5e2a-43a8-8ddb-747e1d2e1a70


# ╔═╡ Cell order:
# ╠═9ee55ad0-bdfe-11f1-b929-4fee718319f6
# ╠═80e280bc-58e9-4822-a114-df50fda303cb
# ╠═a1543d3e-d04d-4a5e-861b-51c3dd8ae77f
# ╠═c89238ca-bbb6-45a5-9c5e-708656653b31
# ╠═75e36201-d78e-4f49-b99b-b6d52ecaa8e7
# ╟─2804165e-d241-493d-8222-7f0486e695ef
# ╟─b3dce772-d171-4f1e-a323-3c82a08a031b
# ╟─6f12600d-b72c-439f-9f5b-fee07bba38e3
# ╟─7fd642aa-bdf9-4141-acb2-edf9f704ffe8
# ╟─19925c2b-b726-4482-ac66-e31748d08d6d
# ╟─ebc5fe9b-88f5-4c1b-b84a-134604f4867e
# ╟─a956645f-859e-457c-83b7-cbe40e6db874
# ╟─fbbb4907-7ed7-4e9d-b1bb-b43fda7c285b
# ╟─39fb4f4d-9e44-4aa8-b92b-9e6e32445e3c
# ╟─e13eb806-a69d-4e31-acd1-78099355d0f8
# ╟─4e83703d-3246-4568-ad0f-90e3491bd00b
# ╟─39a71b6e-a534-43e4-96b2-d426426b3195
# ╟─853e9300-2dc6-4694-bd39-51e22bd87709
# ╟─adc991bd-b4cf-4835-b051-d0e2ca0c9877
# ╟─02b70dc9-da39-4812-9ecc-6848c98a9bbc
# ╟─2cee7e2c-5752-4b93-bc7f-88271396b96a
# ╟─ea6db877-d78b-49e2-bd92-6ecaf0a40ecc
# ╟─6478dcd0-1b4b-40ab-a88f-33ac3b5132f0
# ╟─07da6088-deb7-4f03-8862-23b10aafe4ad
# ╟─13430463-2b22-4564-a125-f869cc327ed2
# ╟─7be1c9b8-cbe7-499c-93ba-93ac4a65269a
# ╟─69de7bde-7238-478a-8e8a-283920978843
# ╟─36066daa-f451-419b-9b4a-ac452bee63d9
# ╟─5ee9618c-dab6-472e-b187-bfd5b77bd4d1
# ╟─1fabc218-b585-4854-aad2-4295e702326d
# ╟─76cc90e9-b276-4ac1-968e-fb502dc124d1
# ╠═1f95d157-8138-4013-bd98-c3d5c609c1b7
# ╠═fa982734-9c0e-451d-b834-687ab1f8b198
# ╠═668b9ef2-c136-47ee-9567-b1e574de9be9
# ╠═ff424e9d-542f-4dff-bd96-9b5b8e14a77b
# ╠═5accfb77-237e-4174-bd78-594bdd19e765
# ╠═d38ef224-0fe2-478b-a107-0a59bb9801c7
# ╠═04acb461-71ff-4d27-b113-f0dfe37e6080
# ╟─c199acb2-81fe-475b-84f6-26f8c1f8138e
# ╠═2c0004e1-b90b-45fc-b84f-6e95d333102c
# ╠═dc17f5b3-5805-4f2a-8396-267cf7ff97ef
# ╠═dc4c2519-e385-493d-bf56-7bf9833f85c5
# ╠═650ed927-a7b5-4208-9f0b-6cd6c79149b9
# ╠═ae234222-fee7-4244-9659-b08d6b025e5a
# ╠═684e791c-b210-43c6-89ed-ea782a59e6ff
# ╠═217c1636-fca2-46df-8324-1a233f3f1e4d
# ╠═5a8fb172-5e2a-43a8-8ddb-747e1d2e1a70
