# This file can be used to create the validation file for deterministic scc values. 
# It will create a validation file containing all possibilities of parameter values 
# defined in the specs dictionary below produce the same results. 

using MimiDICE2016R2
using DataFrames
using Query
using CSVFiles
using Test

specs = Dict([
    :year => [2020, 2510],
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

path = joinpath(@__DIR__, "deterministic_sc_values_v0-1-0.csv")
save(path, results)
