"""
    compute_scc(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.015, eta=1.45)

Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2016R2 model. 
If no model is provided, the default model from MimiDICE2016R2.get_model() is used.
Constant discounting is used from the specified pure rate of time preference `prtp`.
"""
function compute_scc(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.015, eta=1.45)
    year === nothing ? error("Must specify an emission year. Try `compute_scc(m, year=2020)`.") : nothing
    !(last_year in model_years) ? error("Invalid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:5:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):5:$last_year.") : nothing

    mm = get_marginal_model(m; year = year)

    return _compute_scc(mm, year=year, last_year=last_year, prtp=prtp, eta=eta)
end

"""
    compute_scc_mm(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.015, eta=1.45)

Returns a NamedTuple (scc=scc, mm=mm) of the social cost of carbon and the MarginalModel used to compute it.
Computes the social cost of CO2 for an emissions pulse in `year` for the provided MimiDICE2016R2 model. 
If no model is provided, the default model from MimiDICE2016R2.get_model() is used.
Constant discounting is used from the specified pure rate of time preference `prtp`.
"""
function compute_scc_mm(m::Model=get_model(); year::Union{Int, Nothing} = nothing, last_year::Int = model_years[end], prtp::Float64 = 0.015, eta=1.45)
    year === nothing ? error("Must specify an emission year. Try `compute_scc_mm(m, year=2020)`.") : nothing
    !(last_year in model_years) ? error("Invalid value of $last_year for last_year. last_year must be within the model's time index $model_years.") : nothing
    !(year in model_years[1]:5:last_year) ? error("Cannot compute the scc for year $year, year must be within the model's time index $(model_years[1]):5:$last_year.") : nothing

    mm = get_marginal_model(m; year = year)
    scc = _compute_scc(mm; year=year, last_year=last_year, prtp=prtp, eta=eta)
    
    return (scc = scc, mm = mm)
end

# helper function for computing SCC from a MarginalModel, not to be exported or advertised to users
function _compute_scc(mm::MarginalModel; year::Int, last_year::Int, prtp::Float64, eta::Float64)
    ntimesteps = findfirst(isequal(last_year), model_years)     # Will run through the timestep of the specified last_year 
    run(mm, ntimesteps=ntimesteps)

    # Go from trillion$ to $; multiply by -1 so that damages are positive; pulse 
    # was in CO2 so we don't need to multiply by 12/44
    marginal_damages = -1 * mm[:neteconomy, :C][1:ntimesteps] * 1e12    

    cpc = mm.base[:neteconomy, :CPC]

    year_index = findfirst(isequal(year), model_years)

    df = [zeros(year_index-1)..., ((cpc[year_index]/cpc[i])^eta * 1/(1+prtp)^(t-year) for (i,t) in enumerate(model_years) if year<=t<=last_year)...]
    scc = sum(df .* marginal_damages * 5)  # currently implemented as a 5year step function; so each timestep of discounted marginal damages is multiplied by 5
    return scc
end

"""
    get_marginal_model(m::Model=get_model(); year::Union{Int, Nothing} = nothing)

Creates a Mimi MarginalModel where the provided m is the base model, and the marginal model has additional emissions of CO2 in year `year`.
If no Model m is provided, the default model from MimiDICE2016R2.get_model() is used as the base model.
"""
function get_marginal_model(m::Model=get_model(); year::Union{Int, Nothing} = nothing)
    year === nothing ? error("Must specify an emission year. Try `get_marginal_model(m, year=2015)`.") : nothing
    !(year in model_years) ? error("Cannot add marginal emissions in $year, year must be within the model's time index $(model_years[1]):10:$last_year.") : nothing

    # note here that the pulse size will be used as the `delta` parameter for 
    # the `MarginalModel` and thus allow computation of the SCC to return units of
    # dollars per ton, as long as `pulse_size` is in tons
    mm = create_marginal_model(m, 5 * 1e9)    # 1 GtCO2 per year for 5 years, so 5 * 10^9
    add_marginal_emissions!(mm.modified, year)

    return mm
end

"""
    add_marginal_emissions!(m::Model, year::Int) 

Adds a marginal emission component to year m which adds 1Gt of additional CO2 emissions per year for five years starting in the specified `year`.
"""
function add_marginal_emissions!(m::Model, year::Int) 
    add_comp!(m, Mimi.adder, :marginalemission, before=:co2cycle)

    time = Mimi.dimension(m, :time)
    addem = zeros(length(time))
    addem[time[year]] = 1.0     # 1 GtCO2 per year for five years

    update_param!(m, :marginalemission, :add, addem)
    connect_param!(m, :marginalemission, :input, :emissions, :E)
    connect_param!(m, :co2cycle, :E, :marginalemission, :output)
end



# Old available marginal model function 
function getmarginal_dice_models(;emissionyear=2010)

    DICE = constructdice()
    run(DICE)
    
    mm = MarginalModel(DICE)
    m1 = mm.base
    m2 = mm.modified

    add_comp!(m2, adder, :marginalemission, before=:co2cycle)

    time = dimension(m1, :time)
    addem = zeros(length(time))
    addem[time[emissionyear]] = 1.0

    set_param!(m2, :marginalemission, :add, addem)
    connect_param!(m2, :marginalemission, :input, :emissions, :E)
    connect_param!(m2, :co2cycle, :E, :marginalemission, :output)

    run(m1)
    run(m2)

    return m1, m2
end