const PARSERS = Dict{String, Function}()

"""
    parse_metric_bindings(df::DataFrame)

Parses a DataFrame containing metric bindings and returns an array of `MetricBinding` objects.
The DataFrame should contain the following columns:
- `id`: Unique identifier for the metric binding.
- `scenario`: The scenario to which the metric binding applies.
- `endpoint`: The observable (endpoint) associated with the metric binding.
- `metric.type`: The type of metric (e.g., "mean", "category", etc.).
- `active`: (optional) A boolean indicating whether the metric binding is active (default is `true`).
The function uses the `PARSERS` dictionary to find the appropriate parser for the metric type.
The function iterates over each row of the DataFrame, extracting the relevant information and creating a `MetricBinding` object.
    
    Returns
An array of `MetricBinding` objects.
"""
function parse_metric_bindings(df::DataFrame)
    bindings = MetricBinding[]
    for row in eachrow(df)
        mb = try
            (; id, scenario, endpoint, var"metric.type") = row
            active = get(row, :active, true)
            haskey(PARSERS, var"metric.type") || error("Unknown metric type \"$(var"metric.type")\"")
            dp = PARSERS[var"metric.type"](row)

            MetricBinding(id, scenario, dp, endpoint, active)
        catch e
            @error "Failed to process row $(rownumber(row))" row=join(values(row), ",") exception=(e, catch_backtrace())
            throw(e)  # or rethrow(e) to preserve original error trace
        end

        push!(bindings, mb)
    end

    return bindings
end
