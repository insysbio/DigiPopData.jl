import JuMP: VariableRef, AffExpr

const RATE_TOL = 1e-6 # value to comare rates to 1 or 0

# abstract type for Metric
abstract type RealMetric end

#mismatch(_, ::RealMetric) = error("`mismatch` method is not implimented for RealMetric type.")

#mismatch_expression(_, ::RealMetric, ::Vector{VariableRef}, ::Int) = error("`mismatch_expression` method is not implimented for RealMetric type.")