#=
    XXX: Currently we accept NaN values in simulation data.
    It means that value is not exist and must be excluded from statistics, so metrics was created on this data.
=#

struct RealMetricQuantile <: RealMetric
    size::Int
    levels::Vector{Float64}
    values::Vector{Float64}
    skip_nan::Bool # whether to skip NaN values in the simulation data

    cov_inv::Matrix{Float64} # inverse of the covariance matrix of the groups
    group_active::Vector{Bool}
    rates::Vector{Float64} # rates of the groups

    RealMetricQuantile(size::Int, levels::Vector{Float64}, values::Vector{Float64}, skip_nan::Bool = true) = begin
        _validate_quantile(levels, values)

        extended_levels = [0; levels; 1.0]
        rates = [extended_levels[i+1] - extended_levels[i] for i in 1:length(levels) + 1]
        group_active = .!isapprox.(rates, 0., atol=RATE_TOL) # not 0

        len = sum(group_active) - 1 # degree of freedom
        rates_reduced = rates[group_active][1:len] # all non zero without last one
        diag = [i == j ? rates_reduced[i] : 0.0 for i in 1:len, j in 1:len]
        cov = diag - rates_reduced * rates_reduced'
        cov_inv = inv(cov) # TODO: can be done without the inverse matrix

        new(size, levels, values, skip_nan, cov_inv, group_active, rates)
    end
end

_validate_quantile(levels::Vector{Float64}, values::Vector{Float64}) = begin
    # Check equal lengths
    length(levels) == length(values) || 
        throw(ArgumentError("`levels` and `values` must have the same length"))

    # Check that levels are in (0, 1)
    all(0 .< levels .< 1) || 
        throw(ArgumentError("All quantile levels must be in (0, 1), got $(levels)"))

    # Check that levels are sorted ascending
    issorted(levels) || 
        throw(ArgumentError("`levels` must be sorted in ascending order"))

    # check that values are sorted in ascending order
    issorted(values) || 
        throw(ArgumentError("`values` must be sorted in ascending order"))
end

function mismatch(sim::Vector{Float64}, dp::RealMetricQuantile)
    validate(sim, dp)

    len = sum(dp.group_active) - 1 # degree of freedom
    sim1 = filter(x -> !isnan(x), sim) # remove NaN values

    # calculate number of less than values
    count_virt_cum = [sum(sim1 .< dp.values[i]) for i in 1:length(dp.levels)]
    count_virt_cum_ext = [0; count_virt_cum; length(sim1)]
    count_virt = [count_virt_cum_ext[i+1] - count_virt_cum_ext[i] for i in 1:length(count_virt_cum_ext) - 1]
    
    ### TODO: check if the non-active groups are empty

    # calculate the loss
    diff = count_virt .- dp.rates * length(sim) # full count including NaN values
    diff_active = diff[dp.group_active][1:len] # all non zero without last one
    loss = diff_active' * dp.cov_inv * diff_active # quadratic form

    return loss
end

function mismatch_expression(
    sim::AbstractVector{Float64},
    dp::RealMetricQuantile,
    X::Vector{VariableRef},
    X_len::Int
)
    validate(sim, dp)
    # Check that the length of sim and X are equal
    length(sim) == length(X) || throw(DimensionMismatch("Length of simulation data and X must be equal"))
    # Check that X_len is less than sim
    X_len <= length(sim) || throw(DimensionMismatch("X_len must be less than or equal to the length of simulation data"))

    len = sum(dp.group_active) - 1 # degree of freedom
    not_nan = .!isnan.(sim) # mark NaN values

    # calculate the loss
    values_ext = [-Inf; dp.values; Inf]
    diff = AffExpr[]
    for i in 1:length(dp.rates)
        mask = (values_ext[i] .<= sim .< values_ext[i+1]) .&& not_nan # to sort to specific group
        expr = sum(mask .* X) - dp.rates[i] * X_len
        push!(diff, expr)
    end

    ### TODO: check if the non-active groups are empty
    
    diff_active = diff[dp.group_active][1:len] # all non zero without last one   
    loss = diff_active' * dp.cov_inv * diff_active / X_len

    loss
end

function validate(sim::Vector{Float64}, dp::RealMetricQuantile)
    # Check that the simulation data is not empty
    isempty(sim) && 
        throw(ArgumentError("Simulation data cannot be empty"))

    # Check that the simulation data contains no missing values
    any(ismissing, sim) && 
        throw(ArgumentError("Simulation data contains missing values"))

    dp.skip_nan || any(isnan, sim) && 
        throw(ArgumentError("Simulation data contains NaN values which are not allowed when `skip_nan` is false"))    
end

PARSERS["quantile"] = (row) -> begin
    size = row[Symbol("metric.size")]
    levels_string = row[Symbol("metric.levels")]
    levels = parse.(Float64, split(levels_string, ";"))
    values_string = row[Symbol("metric.values")]
    values = parse.(Float64, split(values_string, ";"))
    skip_nan_string = row[Symbol("metric.skip_nan")]
    skip_nan = typeof(skip_nan_string) == String ?
        parse(Bool, skip_nan_string) : 
        skip_nan_string

    RealMetricQuantile(size, levels, values, Bool(skip_nan))
end
