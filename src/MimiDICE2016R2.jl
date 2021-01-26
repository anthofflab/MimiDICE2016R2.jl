module MimiDICE2016R2

using Mimi
using XLSX: readxlsx

include("helpers.jl")
include("parameters.jl")

include("marginaldamage.jl")

include("components/totalfactorproductivity_component.jl")
include("components/grosseconomy_component.jl")
include("components/emissions_component.jl")
include("components/co2cycle_component.jl")
include("components/radiativeforcing_component.jl")
include("components/climatedynamics_component.jl")
include("components/damages_component.jl")
include("components/neteconomy_component.jl")
include("components/welfare_component.jl")

export constructdice, getdiceexcel, getdicegams

const model_years = 2015:5:2510

function constructdice(params)

    m = Model()
    set_dimension!(m, :time, model_years)

    #--------------------------------------------------------------------------
    # Add components in order
    #--------------------------------------------------------------------------

    add_comp!(m, totalfactorproductivity, :totalfactorproductivity)
    add_comp!(m, grosseconomy, :grosseconomy)
    add_comp!(m, emissions, :emissions)
    add_comp!(m, co2cycle, :co2cycle)
    add_comp!(m, radiativeforcing, :radiativeforcing)
    add_comp!(m, climatedynamics, :climatedynamics)
    add_comp!(m, damages, :damages)
    add_comp!(m, neteconomy, :neteconomy)
    add_comp!(m, welfare, :welfare)

    #--------------------------------------------------------------------------
    # Make internal parameter connections
    #--------------------------------------------------------------------------
    
    # Socioeconomics
    connect_param!(m, :grosseconomy, :AL, :totalfactorproductivity, :AL)
    connect_param!(m, :grosseconomy, :I, :neteconomy, :I)
    connect_param!(m, :emissions, :YGROSS, :grosseconomy, :YGROSS)

    # Climate
    connect_param!(m, :co2cycle, :E, :emissions, :E)
    connect_param!(m, :radiativeforcing, :MAT, :co2cycle, :MAT)
    connect_param!(m, :climatedynamics, :FORC, :radiativeforcing, :FORC)

    # Damages
    connect_param!(m, :damages, :TATM, :climatedynamics, :TATM)
    connect_param!(m, :damages, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :YGROSS, :grosseconomy, :YGROSS)
    connect_param!(m, :neteconomy, :DAMAGES, :damages, :DAMAGES)
	connect_param!(m, :neteconomy, :SIGMA, :emissions, :SIGMA)
    connect_param!(m, :welfare, :CPC, :neteconomy, :CPC)

    #--------------------------------------------------------------------------
    # Set external parameter values 
    #--------------------------------------------------------------------------
    for (name, value) in params
        set_param!(m, name, value)
    end
    
    return m

end

function getdiceexcel(;datafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016R-090916ap-v2_R2update.xlsm"))
    params = getdice2016excelparameters(datafile)

    m = constructdice(params)

    return m
end

function getdicegams(;gamsdatafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016_IAMF_Parameters_R2update.xlsx"), exceldatafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016R-090916ap-v2_R2update.xlsm"))
    params = getdice2016gamsparameters(gamsdatafile, exceldatafile)

    m = constructdice(params)

    return m
end

# get_model function for standard Mimi API: use the Excel version
get_model = getdiceexcel

end # module