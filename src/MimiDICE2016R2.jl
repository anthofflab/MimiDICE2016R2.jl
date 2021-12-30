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

export constructdice, getdiceexcel

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
    # Set unshared parameters - name is a Tuple{Symbol, Symbol} of (component_name, param_name)
    for (name, value) in params[:unshared]
        update_param!(m, name[1], name[2], value)
    end
    
    # Set shared parameters - name is a Symbol representing the param_name, here
    # we will create a shared model parameter with the same name as the component
    # parameter and then connect our component parameters to this shared model parameter
    add_shared_param!(m, :fco22x, params[:shared][:fco22x]) #Forcings of equilibrium CO2 doubling (Wm-2)
    connect_param!(m, :climatedynamics, :fco22x, :fco22x)
    connect_param!(m, :radiativeforcing, :fco22x, :fco22x)

    add_shared_param!(m, :l, params[:shared][:l], dims = [:time]) #Level of population and labor (millions)
    connect_param!(m, :grosseconomy, :l, :l)
    connect_param!(m, :neteconomy, :l, :l)
    connect_param!(m, :welfare, :l, :l)

    add_shared_param!(m, :MIU, params[:shared][:MIU], dims = [:time]) #Optimized emission control rate results from DICE2016R (base case)
    connect_param!(m, :neteconomy, :MIU, :MIU)
    connect_param!(m, :emissions, :MIU, :MIU)
    
    return m

end

function getdiceexcel(;datafile = joinpath(dirname(@__FILE__), "..", "data", "DICE2016R-090916ap-v2-REVISEDtoR2.xlsm"))
    params = getdice2016r2excelparameters(datafile)

    m = constructdice(params)

    return m
end

# get_model function for standard Mimi API: use the Excel version
get_model = getdiceexcel

include("mcs.jl")

end # module