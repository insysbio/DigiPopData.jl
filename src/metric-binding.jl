using DataFrames

# store data and connection to endpoint
struct MetricBinding
    id::String # not sure this is needed
    scenario::String
    metric::RealMetric
    endpoint::String
    active::Bool
end

# TODO: for future use, when we need check all data befor we start calculation
function _validate_simulated(simulated::DataFrame, metric_bindings::Vector{MetricBinding})

end

### Main function of the module

# calculated for selected patients in the cohort
function get_loss(simulated::DataFrame, metric_bindings::Vector{MetricBinding}, cohort::Vector{String}) 
    # select subset of DataFrame
    selected = in.(df.id, Ref(cohort))
    simulated_subset = simulated[selected, :]

    get_loss(simulated_subset, metric_bindings)
end

# calculate for all patients in the cohort
function get_loss(simulated::DataFrame, metric_bindings::Vector{MetricBinding})
    _validate_simulated(simulated, metric_bindings)

    loss = 0.0
    for b in metric_bindings
        !b.active && continue # skip inactive metric bindings
        # select only endpoint which refers to scenario
        selected = simulated[simulated.scenario .== b.scenario, b.endpoint]
        loss += mismatch(selected, b.metric)
    end

    return loss
end
