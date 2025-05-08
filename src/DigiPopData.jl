
module DigiPopData

include("real-metric-types/real-metric.jl")
include("metric-binding.jl")
include("loaders.jl")

export mismatch, mismatch_expression
export MetricBinding, get_loss
export loadMetricBindings

# list of data point types can be extended by adding new types to this list
include("real-metric-types/real-metric-mean.jl")
include("real-metric-types/real-metric-mean-sd.jl")
include("real-metric-types/real-metric-category.jl")
include("real-metric-types/real-metric-quantile.jl")
include("real-metric-types/real-metric-survival.jl")

export RealMetricMean, RealMetricMeanSD, RealMetricCategory, RealMetricQuantile, RealMetricSurvival

end
