using DigiPopData, JuMP
using Test

@testset "DigiPopData" begin
    @testset "MetricMean unit tests" begin include("metric-mean.jl") end
    @testset "MetricMeanSD unit tests" begin include("metric-mean-sd.jl") end
end