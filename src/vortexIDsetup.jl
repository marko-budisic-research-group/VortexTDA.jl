function casesetup(idType)

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
	
		idMatrix = "$(idMatrix_2Name[idType])"

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

	idMethod = "$(idTypeToFile[idType])"

    # filter which homology group is relevant to vortex ID method, 
    # and choose relevant side of filtration 
	if idType == :Vorticity
		cutoffType = :cut_vorticity
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
        rangeVar = :range_vorticity
	elseif idType == :Q_Characteristic
		cutoffType = :cut_Q 
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
        rangeVar = :range_Q 
	elseif idType == :Truesdell_No
		cutoffType = :cut_Truesdell
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
        rangeVar = :range_Truesdell
	elseif idType == :Omega_Rortex
		cutoffType = :cut_OmegaR
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
        rangeVar = :range_OmegaR
	elseif idType == :Lambda_2
		cutoffType = :cut_Lambda2
		sublevel_H0 = true
		superlevel_H0 = false
		sublevel_H1 = false
		superlevel_H1 = true
        rangeVar = :range_Lambda2
	elseif idType == :Delta_Discriminant
		cutoffType = :cut_Delta
		sublevel_H0 = false
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = false
        rangeVar = :range_Delta
	elseif idType == :Lambda_ci
		cutoffType = :cut_LambdaCi
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
        rangeVar = :range_LambdaCi
	elseif idType == :Rortex
		cutoffType = :cut_Rortex
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
        rangeVar = :range_Rortex
	elseif idType == :R_Characteristic
		cutoffType = :cut_R
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
        rangeVar = :range_R
	else 
		cutoffType = 0
		sublevel_H0 = true
		superlevel_H0 = true
		sublevel_H1 = true
		superlevel_H1 = true
        rangeVar = 0
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

	idCutoff = idCutoff_2Var[cutoffType]
	levelsetH0 = (sublevel_H0,superlevel_H0)
	levelsetH1 = (sublevel_H1,superlevel_H1)

    returnVars = (idMatrix, idMethod, idCutoff, levelsetH0, levelsetH1, rangeVar)    
    return returnVars
end
