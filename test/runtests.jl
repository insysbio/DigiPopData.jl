using DigiPopData, JuMP
using Test

@testset "DigiPopData" begin
    @testset "MeanMetric unit tests" begin include("mean-metric.jl") end
    @testset "MeanSDMetric unit tests" begin include("mean-sd-metric.jl") end
end