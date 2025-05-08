# function loading CSV file into array of MetricBinding
using CSV

const PARSERS = Dict{String, Function}()

function loadMetricBindings(file_path::String)
    data = CSV.File(file_path; silencewarnings=true)

    connections = MetricBinding[]
    for i in eachindex(data)
        row = data[i]
        connection = try
            (; id, active, scenario, endpoint, var"metric.type") = row

            haskey(PARSERS, var"metric.type") || error("Unknown metric type $(var"metric.type")")
            dp = PARSERS[var"metric.type"](row)

            MetricBinding(id, scenario, dp, endpoint, active)
        catch e
            @error "Failed to process row $i" row=join(values(data[i]), ",") exception=(e, catch_backtrace())
            throw(e)  # or rethrow(e) to preserve original error trace
        end

        push!(connections, connection)
    end

    return connections
end
