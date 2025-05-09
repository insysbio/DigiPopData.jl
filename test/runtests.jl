using DigiPopData, JuMP
using DataFrames
using Test

@testset "DigiPopData Metric unit tests" begin
    @testset "MeanMetric unit tests" begin include("mean-metric.jl") end
    @testset "MeanSDMetric unit tests" begin include("mean-sd-metric.jl") end
    @testset "CategoryMetric unit tests" begin include("category-metric.jl") end
    @testset "QuantileMetric unit tests" begin include("quantile-metric.jl") end
    @testset "SurvivalMetric unit tests" begin include("survival-metric.jl") end
end

@testset "DigiPopData other unit tests" begin
    @testset "MetricBinding unit tests" begin include("metric-binding.jl") end
end