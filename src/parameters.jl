using XLSX: readxlsx

"""
Get DICE2016R2 default Excel parameters. Returns a Dictionary with two keys,
:shared and :unshared, each holding a Dictionary of shared (keys are a Tuple of 
(component_name, parameter_name) and unshared (keys are parameter_name) parameter 
values.
"""
function getdice2016r2excelparameters(filename)
    p_unshared = Dict{Tuple{Symbol, Symbol},Any}()
    p_shared = Dict{Symbol, Any}()

    T = 100
    
    #Open DICE_2016R2 Excel File to Read Parameters - file revised to reflect change in damage coefficient
    f = readxlsx(filename)

    #
    # SHARED PARAMETERS 
    #
    
    p_shared[:fco22x] = getparams(f, "B80:B80", :single, "Base", 1) #Forcings of equilibrium CO2 doubling (Wm-2)
    p_shared[:l]      = getparams(f, "B53:CW53", :all, "Base", T) #Level of population and labor (millions)
    p_shared[:MIU]    = getparams(f, "B135:CW135", :all, "Base", T) #Optimized emission control rate results from DICE2016R (base case)

    #
    # COMPONENT PARAMETERS 
    #

	p_unshared[(:totalfactorproductivity, :a0)]   = getparams(f, "B108:B108", :single, "Parameters",1) #Initial level of total factor productivity
    p_unshared[(:totalfactorproductivity, :ga0)]  = getparams(f, "B109:B109", :single, "Parameters",1) #Initial growth rate for TFP per 5 years
    p_unshared[(:totalfactorproductivity, :dela)]   = getparams(f, "B110:B110", :single, "Parameters",1) #Decline rate of TFP per 5 years

    p_unshared[(:grosseconomy, :dk)]      = getparams(f, "B6:B6", :single, "Base", 1)     #Depreciation rate on capital (per year)
    p_unshared[(:grosseconomy, :k0)]      = getparams(f, "B12:B12", :single, "Base", 1)   #Initial capital
    p_unshared[(:grosseconomy, :gama)]    = getparams(f, "B5:B5", :single, "Base", 1)     #Capital Share
    
    p_unshared[(:emissions, :cca0)]       = getparams(f, "B92:B92", :single, "Base", 1)       #Initial cumulative industrial emissions
    p_unshared[(:emissions, :cumetree0)]  = 100                                               #Initial cumulative emissions from deforestation (see GAMS code)
	p_unshared[(:emissions, :deland)]     = getparams(f, "D64:D64", :single, "Parameters", 1) #Decline rate of land emissions (per period)
	p_unshared[(:emissions, :dsig)]       = getparams(f, "B66:B66", :single, "Parameters", 1) #Decline rate of decarbonization (per period)
	p_unshared[(:emissions, :eland0)]     = getparams(f, "D63:D63", :single, "Parameters", 1) #Carbon emissions from land 2015 (GtCO2 per year)
	p_unshared[(:emissions, :e0)]         = getparams(f, "B113:B113", :single, "Base", 1)     #Industrial emissions 2015 (GtCO2 per year)
    p_unshared[(:emissions, :gsigma1)]    = getparams(f, "B15:B15", :single, "Parameters", 1)	#Initial growth of sigma (per year)

    p_unshared[(:co2cycle, :b12)]     = getparams(f, "B67:B67", :single, "Base", 1)       #Carbon cycle transition matrix atmosphere to shallow ocean
    p_unshared[(:co2cycle, :b23)]     = getparams(f, "B70:B70", :single, "Base", 1)       #Carbon cycle transition matrix shallow to deep ocean
    p_unshared[(:co2cycle, :mat0)]    = getparams(f, "B61:B61", :single, "Base", 1)       #Initial Concentration in atmosphere in 2015 (GtC)
	p_unshared[(:co2cycle, :mateq)]   = getparams(f, "B82:B82", :single, "Parameters", 1) #Equilibrium concentration atmosphere  (GtC)
    p_unshared[(:co2cycle, :ml0)]     = getparams(f, "B63:B63", :single, "Base", 1)       #Initial Concentration in deep oceans 2010 (GtC)
	p_unshared[(:co2cycle, :mleq)]    = getparams(f, "B84:B84", :single, "Parameters", 1) #Equilibrium concentration in lower strata (GtC)
    p_unshared[(:co2cycle, :mu0)]     = getparams(f, "B62:B62", :single, "Base", 1)       #Initial Concentration in biosphere/shallow oceans 2010 (GtC)
	p_unshared[(:co2cycle, :mueq)]    = getparams(f, "B83:B83", :single, "Parameters", 1) #Equilibrium concentration in upper strata (GtC)
   
    p_unshared[(:radiativeforcing, :eqmat)]   = getparams(f, "B82:B82", :single, "Parameters", 1) #Equilibirum concentration of CO2 in atmosphere (GTC)
	p_unshared[(:radiativeforcing, :fex0)]    = getparams(f, "B87:B87", :single, "Parameters", 1) #2015 forcings of non-CO2 GHG (Wm-2)
	p_unshared[(:radiativeforcing, :fex1)]    = getparams(f, "B88:B88", :single, "Parameters", 1) #2100 forcings of non-CO2 GHG (Wm-2)
	
    p_unshared[(:climatedynamics, :c1)]       = getparams(f, "B82:B82", :single, "Base", 1)   #Speed of adjustment parameter for atmospheric temperature (per 5 years)
    p_unshared[(:climatedynamics, :c3)]       = getparams(f, "B83:B83", :single, "Base", 1)   #Coefficient of heat loss from atmosphere to oceans
    p_unshared[(:climatedynamics, :c4)]       = getparams(f, "B84:B84", :single, "Base", 1)   #Coefficient of heat gain by deep oceans
    p_unshared[(:climatedynamics, :t2xco2)]   = getparams(f, "B79:B79", :single, "Base", 1)   #Equilibrium temp impact (oC per doubling CO2)
    p_unshared[(:climatedynamics, :tatm0)]    = getparams(f, "B76:B76", :single, "Base", 1)   #Initial atmospheric temp change 2015 (C from 1940-60)
    p_unshared[(:climatedynamics, :tocean0)]  = getparams(f, "B77:B77", :single, "Base", 1)   #Initial temperature of deep oceans (deg C above 1940-60)

    p_unshared[(:damages, :a1)]   = getparams(f, "B25:B25", :single, "Base", 1)   #Damage coefficient on temperature
    p_unshared[(:damages, :a2)]   = getparams(f, "B26:B26", :single, "Base", 1)   #Damage quadratic term
    p_unshared[(:damages, :a3)]   = getparams(f, "B27:B27", :single, "Base", 1)   #Damage exponent

    p_unshared[(:neteconomy, :gback)]       = getparams(f, "B26:B26", :single, "Parameters", 1) #Initial cost decline backstop cost per period
    p_unshared[(:neteconomy, :expcost2)]    = getparams(f, "B39:B39", :single, "Base", 1)       #Exponent of control cost function
    p_unshared[(:neteconomy, :pback)]       = getparams(f, "B10:B10", :single, "Parameters", 1)     #Cost of backstop 2010$ per tCO2 2015
    p_unshared[(:neteconomy, :S)]           = getparams(f, "B131:CW131", :all, "Base", T) #Optimized savings rate (fraction of gross output) results from DICE2016 (base case)

    p_unshared[(:welfare, :rr)]       = getparams(f, "B18:CW18", :all, "Base", T)     #Social Time Preference Factor
    p_unshared[(:welfare, :scale1)]   = getparams(f, "B49:B49", :single, "Base", 1)   #Multiplicative scaling coefficient
    p_unshared[(:welfare, :scale2)]   = getparams(f, "B50:B50", :single, "Base", 1)   #Additive scaling coefficient
    p_unshared[(:welfare, :elasmu)]   = getparams(f, "B19:B19", :single, "Base", 1)   #Elasticity of MU of consumption

    return Dict(:shared => p_shared, :unshared => p_unshared)
    
end
