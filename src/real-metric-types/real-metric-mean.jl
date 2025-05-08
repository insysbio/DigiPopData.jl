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
    # Check that standard deviation is finite
    isfinite(sd) || throw(ArgumentError("Standard deviation must be finite"))
    # Check that standard deviation is not NaN
    !isnan(sd) || throw(ArgumentError("Standard deviation must not be NaN"))
    # Check that mean is finite
    isfinite(mean) || throw(ArgumentError("Mean must be finite"))
    # Check that mean is not NaN
    !isnan(mean) || throw(ArgumentError("Mean must not be NaN"))
end

function mismatch(sim::AbstractVector{<:Real}, dp::RealMetricMean)
    validate(sim, dp)

    mu_virt = sum(sim) / length(sim)
    loss = length(sim) * (mu_virt - dp.mean)^2 / dp.sd^2

    loss
end

function mismatch_expression(sim::AbstractVector{<:Real}, dp::RealMetricMean, X::Vector{VariableRef}, X_len::Int)
    validate(sim, dp)
    # Check that the length of sim and X are equal
    length(sim) == length(X) || throw(DimensionMismatch("Length of simulation data and X must be equal"))
    # Check that X_len is less than sim
    X_len <= length(sim) || throw(DimensionMismatch("X_len must be less than or equal to the length of simulation data"))

    mu_virt = sum(sim .* X) / X_len
    loss = X_len * (mu_virt - dp.mean)^2 / dp.sd^2

    loss
end

function validate(sim::AbstractVector{<:Real}, ::RealMetricMean)
    # length must be >= 3
    length(sim) >= 3 || 
        throw(ArgumentError("Simulation data must have at least 3 elements"))

    # no NaN values
    any(isnan, sim) && 
        throw(ArgumentError("Simulation data contains NaN values"))

    # no Inf values
    any(isinf, sim) && 
        throw(ArgumentError("Simulation data contains Inf values"))
end

PARSERS["mean"] = (row) -> begin
    size = row[Symbol("metric.size")]
    mean_string = row[Symbol("metric.mean")]
    mean = parse(Float64, mean_string)
    sd_string = row[Symbol("metric.sd")]
    sd = parse(Float64, sd_string)

    RealMetricMean(size, mean, sd)
end
