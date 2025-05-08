import JuMP: VariableRef, AffExpr

const RATE_TOL = 1e-6 # value to comare rates to 1 or 0

# abstract type for Metric
abstract type AbstractMetric end

#mismatch(_, ::AbstractMetric) = error("`mismatch` method is not implimented for Metric type.")

#mismatch_expression(_, ::AbstractMetric, ::Vector{VariableRef}, ::Int) = error("`mismatch_expression` method is not implimented for Metric type.")