using DataFrames

"""
    MetricBinding(
        id::String,
        scenario::String,
        metric::AbstractMetric,
        endpoint::String,
        active::Bool
    )

Structure which is container that binds a **scenario**, an **endpoint** and a concrete
`AbstractMetric` description into a single unit that can be logged,
displayed or passed to optimisation / validation routines.

# Fields
| Name        | Type                     | Description                                               |
|-------------|--------------------------|-----------------------------------------------------------|
| `id`        | `String`                 | Unique identifier of the binding |
| `scenario`  | `String`                 | Scenario (e.g. simulation arm) in which the metric is evaluated |
| `metric`    | `AbstractMetric`         | Metric implementation (`MeanMetric`, `CategoryMetric`, …) |
| `endpoint`  | `String`                 | Observable / model variable the metric is computed for    |
| `active`    | `Bool`                   | Whether the binding is enabled (`true` by default)        |

## Returns
`MetricBinding`
"""
struct MetricBinding
    id::String # not sure this is needed
    scenario::String
    metric::AbstractMetric
    endpoint::String
    active::Bool
end

# TODO: for future use, when we need check all data before we start calculation
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
"""
    get_loss(simulated::DataFrame, metric_bindings::Vector{MetricBinding})

Calculate the loss for a given set of metric bindings and a simulated DataFrame.
The function iterates over the metric bindings, selecting the relevant data from the simulated DataFrame
 based on the scenario and endpoint specified in each binding. It then computes the loss using the `mismatch`
 function defined in the metric.

## Arguments
- `simulated::DataFrame`: A DataFrame containing the simulated data.
- `metric_bindings::Vector{MetricBinding}`: A vector of `MetricBinding` objects, each containing a scenario,
endpoint, and metric.

## Returns
- `loss::Float64`: The total loss calculated as the sum of the individual losses from each metric binding.
"""
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
