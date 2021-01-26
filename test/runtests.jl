using Test
using XLSX: readxlsx
using DataFrames
using Mimi
using MimiDICE2016R2
using CSVFiles

using MimiDICE2016R2: getparams

@testset "MimiDICE2016R2" begin

#------------------------------------------------------------------------------
#   1. Run tests on the whole Excel model
#------------------------------------------------------------------------------

@testset "MimiDICE2016R2-excel-model" begin

m = MimiDICE2016R2.get_model();
run(m)

f = readxlsx(joinpath(@__DIR__, "../data/DICE2016R-090916ap-v2_R2update.xlsm"))

#Test Precision
Precision = 1.0e-10

#Time Periods
T=100

#TATM Test (temperature increase)
True_TATM = getparams(f, "B99:CW99", :all, "Base", T);
@test maximum(abs, m[:climatedynamics, :TATM] .- True_TATM) ≈ 0. atol = Precision

#MAT Test (carbon concentration atmosphere)
True_MAT = getparams(f, "B87:CW87", :all, "Base", T);
@test maximum(abs, m[:co2cycle, :MAT] .- True_MAT) ≈ 0. atol = Precision

#DAMFRAC Test (damages fraction)
True_DAMFRAC = getparams(f, "B105:CW105", :all, "Base", T);
@test maximum(abs, m[:damages, :DAMFRAC] .- True_DAMFRAC) ≈ 0. atol = Precision

#DAMAGES Test (damages $)
True_DAMAGES = getparams(f, "B106:CW106", :all, "Base", T);
@test maximum(abs, m[:damages, :DAMAGES] .- True_DAMAGES) ≈ 0. atol = Precision

#E Test (emissions)
True_E = getparams(f, "B112:CW112", :all, "Base", T);
@test maximum(abs, m[:emissions, :E] .- True_E) ≈ 0. atol = Precision

#YGROSS Test (gross output)
True_YGROSS = getparams(f, "B104:CW104", :all, "Base", T);
@test maximum(abs, m[:grosseconomy, :YGROSS] .- True_YGROSS) ≈ 0. atol = Precision

#AL test (total factor productivity)
True_AL = getparams(f, "B21:CW21", :all, "Base", T);
@test maximum(abs, m[:totalfactorproductivity, :AL] .- True_AL) ≈ 0. atol = Precision

#CPC Test (per capita consumption)
True_CPC = getparams(f, "B126:CW126", :all, "Base", T);
@test maximum(abs, m[:neteconomy, :CPC] .- True_CPC) ≈ 0. atol = Precision

#FORCOTH Test (exogenous forcing)
True_FORCOTH = getparams(f, "B73:CW73", :all, "Base", T);
@test maximum(abs, m[:radiativeforcing, :FORCOTH] .- True_FORCOTH) ≈ 0. atol = Precision

#FORC Test (radiative forcing)
True_FORC = getparams(f, "B100:CW100", :all, "Base", T);
@test maximum(abs, m[:radiativeforcing, :FORC] .- True_FORC) ≈ 0. atol = Precision

#Utility Test
True_UTILITY = getparams(f, "B129:B129", :single, "Base", T);
@test maximum(abs, m[:welfare, :UTILITY] .- True_UTILITY) ≈ 0. atol = Precision

end #MimiDICE2016R2-excel-model testset

#------------------------------------------------------------------------------
#   2. Run tests on the whole gams model
#------------------------------------------------------------------------------
@testset "MimiDICE2016R2-gams-model" begin

gams_results = CSVFiles.load(joinpath(@__DIR__, "../data/DICE2016R2-GAMS-Results-select.csv")) |> DataFrame

Precision = 1.0e-10

end #MimiDICE2016R2-gams-model testset

#------------------------------------------------------------------------------
#   3. Run tests on SCC
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
update_param!(m, :t2xco2, 5)    
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

end #MimiDICE2016R2 testset

nothing