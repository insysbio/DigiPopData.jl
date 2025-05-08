struct RealMetricMean <: RealMetric
    size::Int
    mean::Float64
    sd::Float64

    RealMetricMean(size::Int, mean::Float64, sd::Float64) = begin
        _validate_mean(mean, sd)
        new(size, mean, sd)
    end
end

_validate_mean(mean::Float64, sd::Float64) = begin
    # Check that standard deviation is positive
    sd > 0 || throw(ArgumentError("Standard deviation must be positive"))
end

function mismatch(sim::Vector{Float64}, dp::RealMetricMean)
    validate(sim, dp)

    mu_virt = mean(sim)
    loss = length(sim) * (mu_virt - dp.mean)^2 / dp.sd^2

    loss
end

function mismatch_expression(sim::Vector{Float64}, dp::RealMetricMean, X::Vector{VariableRef}, X_len::Int)
    validate(sim, dp)

    mu_virt = sum(sim .* X) / X_len
    loss = X_len * (mu_virt - dp.mean)^2 / dp.sd^2

    loss
end

function validate(sim::Vector{Float64}, ::RealMetricMean)
    # length must be >= 3
    length(sim) >= 3 || 
        throw(ArgumentError("Simulation data must have at least 3 elements"))

    # no NaN values
    any(isnan, sim) && 
        throw(ArgumentError("Simulation data contains NaN values"))

    # no Inf values
    any(isinf, sim) && 
        throw(ArgumentError("Simulation data contains Inf values"))

    # no missing values
    any(ismissing, sim) && 
        throw(ArgumentError("Simulation data contains missing values"))
end

PARSERS["mean"] = (row) -> begin
    size = row[Symbol("metric.size")]
    mean_string = row[Symbol("metric.mean")]
    mean = parse(Float64, mean_string)
    sd_string = row[Symbol("metric.sd")]
    sd = parse(Float64, sd_string)

    RealMetricMean(size, mean, sd)
end
