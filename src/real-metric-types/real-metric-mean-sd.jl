struct RealMetricMeanSD <: RealMetric
    size::Int
    mean::Float64
    sd::Float64

    RealMetricMeanSD(size::Int, mean::Float64, sd::Float64) = begin
        _validate_mean_sd(mean, sd)
        new(size, mean, sd)
    end
end

_validate_mean_sd(mean::Float64, sd::Float64) = begin
    # Check that standard deviation is positive
    sd > 0 || throw(ArgumentError("Standard deviation must be positive"))
end

function mismatch(sim::Vector{Float64}, dp::RealMetricMeanSD)
    validate(sim, dp)

    mu_virt = mean(sim)
    sigma_sq_virt = var(sim)
    loss1 = length(sim) * (mu_virt - dp.mean)^2 / dp.sd^2
    loss2 = length(sim) / 2 * (sigma_sq_virt - dp.sd^2)^2 / dp.sd^4

    loss1 + loss2
end

function mismatch_expression(sim::Vector{Float64}, dp::RealMetricMeanSD, X::Vector{VariableRef}, X_len::Int)
    validate(sim, dp)

    mu_virt = sum(sim .* X) / X_len
    sigma_sq_virt = sum(sim .^2 .* X) / X_len - mu_virt^2
    loss1 = X_len * (mu_virt - dp.mean)^2 / dp.sd^2
    loss2 = X_len / 2 * (sigma_sq_virt - dp.sd^2)^2 / dp.sd^4

    loss1 + loss2
end

function validate(sim::Vector{Float64}, ::RealMetricMeanSD)
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

PARSERS["mean_sd"] = (row) -> begin
    size = row[Symbol("metric.size")]
    mean_string = row[Symbol("metric.mean")]
    mean = parse(Float64, mean_string)
    sd_string = row[Symbol("metric.sd")]
    sd = parse(Float64, sd_string)

    RealMetricMeanSD(size, mean, sd)
end
