using DigiPopData, JuMP
using Test

@testset "DigiPopData unit tests" begin
    @testset "MeanMetric unit tests" begin include("mean-metric.jl") end
    @testset "MeanSDMetric unit tests" begin include("mean-sd-metric.jl") end
    @testset "CategoryMetric unit tests" begin include("category-metric.jl") end
    @testset "QuantileMetric unit tests" begin include("quantile-metric.jl") end
    @testset "SurvivalMetric unit tests" begin include("survival-metric.jl") end
end