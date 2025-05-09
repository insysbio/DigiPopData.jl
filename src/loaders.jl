const PARSERS = Dict{String, Function}()

function parse_metric_bindings(df::DataFrame)
    bindings = MetricBinding[]
    for row in eachrow(df)
        mb = try
            (; id, active, scenario, endpoint, var"metric.type") = row

            haskey(PARSERS, var"metric.type") || error("Unknown metric type $(var"metric.type")")
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
