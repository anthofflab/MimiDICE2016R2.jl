using Test
using XLSX: readxlsx
using DataFrames
using Mimi
using MimiDICE2016R2
using CSVFiles

using MimiDICE2016R2: getparams

@testset "MimiDICE2016R2" begin

    #------------------------------------------------------------------------------
    #   1. Run tests on the whole model
    #------------------------------------------------------------------------------

    @testset "MimiDICE2016R2-model" begin


        df = load(joinpath(@__DIR__, "../data/DICE2016-R2-GAMSoutputs.csv")) |> DataFrame

        m = MimiDICE2016R2.get_model();
        run(m)

        # TODO: validate this model, noting we will need to update certain parameters 
        # and rerun the Mimi version so that we are imitating the optimized pathway
        # in GAMS

        #Test Precision
        Precision = 1.0e-10

        #Time Periods
        T=100

        # #TATM Test (temperature increase)
        # @test maximum(abs, m[:climatedynamics, :TATM] .- True_TATM) ≈ 0. atol = Precision

        # #MAT Test (carbon concentration atmosphere)
        # @test maximum(abs, m[:co2cycle, :MAT] .- True_MAT) ≈ 0. atol = Precision

        # #DAMFRAC Test (damages fraction)
        # @test maximum(abs, m[:damages, :DAMFRAC] .- True_DAMFRAC) ≈ 0. atol = Precision

        # #DAMAGES Test (damages $)
        # @test maximum(abs, m[:damages, :DAMAGES] .- True_DAMAGES) ≈ 0. atol = Precision

        # #E Test (emissions)
        # @test maximum(abs, m[:emissions, :E] .- True_E) ≈ 0. atol = Precision

        # #YGROSS Test (gross output)
        # @test maximum(abs, m[:grosseconomy, :YGROSS] .- True_YGROSS) ≈ 0. atol = Precision

        # #AL test (total factor productivity)
        # @test maximum(abs, m[:totalfactorproductivity, :AL] .- True_AL) ≈ 0. atol = Precision

        # #CPC Test (per capita consumption)
        # @test maximum(abs, m[:neteconomy, :CPC] .- True_CPC) ≈ 0. atol = Precision

        # #FORCOTH Test (exogenous forcing)
        # @test maximum(abs, m[:radiativeforcing, :FORCOTH] .- True_FORCOTH) ≈ 0. atol = Precision

        # #FORC Test (radiative forcing)
        # @test maximum(abs, m[:radiativeforcing, :FORC] .- True_FORC) ≈ 0. atol = Precision

        # #Utility Test
        # @test maximum(abs, m[:welfare, :UTILITY] .- True_UTILITY) ≈ 0. atol = Precision

    end #MimiDICE2016R2-model testset

    #------------------------------------------------------------------------------
    #   2. Run tests on SCC
    #------------------------------------------------------------------------------

    @testset "Standard API" begin

        m = MimiDICE2016R2.get_model()
        run(m)

        # Test the errors
        @test_throws ErrorException MimiDICE2016R2.compute_scc()  # test that it errors if you don't specify a year
        @test_throws ErrorException MimiDICE2016R2.compute_scc(year=2021)  # test that it errors if the year isn't in the time index
        @test_throws ErrorException MimiDICE2016R2.compute_scc(last_year=2299)  # test that it errors if the last_year isn't in the time index
        @test_throws ErrorException MimiDICE2016R2.compute_scc(year=2105, last_year=2100)  # test that it errors if the year is after last_year

        # Test the SCC 
        scc1 = MimiDICE2016R2.compute_scc(year=2020)
        @test scc1 isa Float64

        # Test that it's smaller with a shorter horizon
        scc2 = MimiDICE2016R2.compute_scc(year=2020, last_year=2200)
        @test scc2 < scc1

        # Test that it's smaller with a larger prtp
        scc3 = MimiDICE2016R2.compute_scc(year=2020, last_year=2200, prtp=0.02)
        @test scc3 < scc2

        # Test with a modified model 
        m = MimiDICE2016R2.get_model()
        update_param!(m, :climatedynamics, :t2xco2, 5)
        scc4 = MimiDICE2016R2.compute_scc(m, year=2020)
        @test scc4 > scc1   # Test that a higher value of climate sensitivty makes the SCC bigger

        # Test compute_scc_mm
        result = MimiDICE2016R2.compute_scc_mm(year=2030)
        @test result.scc isa Float64
        @test result.mm isa Mimi.MarginalModel
        marginal_temp = result.mm[:climatedynamics, :TATM]
        @test all(marginal_temp[1:findfirst(isequal(2030), MimiDICE2016R2.model_years)] .== 0.)
        @test all(marginal_temp[findfirst(isequal(2035), MimiDICE2016R2.model_years):end] .!= 0.)

    end


    # ------------------------------------------------------------------------------
    #   3. Deterministic SCC values
    # ------------------------------------------------------------------------------
    @testset "SCC values" begin

        atol = 1e-6 # TODO what is a reasonable tolerance given we test on a few different machines etc.

        # Test several validation configurations against the pre-saved values from previous version MimiDICE2016R2
        specs = Dict([
            :year => [2020],
            :eta => [0, 1.5],
            :prtp => [0.015, 0.03],
            :last_year => [2200, 2300],
        ])
        
        results = DataFrame(year = [], eta = [], prtp = [], last_year = [], SC = [])
        
        for year in specs[:year]
            for eta in specs[:eta]
                for prtp in specs[:prtp]
                    for last_year in specs[:last_year]
                        sc = MimiDICE2016R2.compute_scc(year=Int(year), eta=eta, prtp=prtp, last_year=Int(last_year))
                        push!(results, (year, eta, prtp, last_year, sc))
                    end
                end
            end
        end
            
        validation_results = load(joinpath(@__DIR__, "..", "data", "SC validation data", "deterministic_sc_values_v0-1-0.csv")) |> DataFrame
        # println("MAXIMUM DIFF IS $(maximum(results[!, :SC] - validation_results[!, :SC]))")
        @test all(isapprox.(results[!, :SC], validation_results[!, :SC], atol = atol))

    end # SCC values testset

end #MimiDICE2016R2 testset

nothing
