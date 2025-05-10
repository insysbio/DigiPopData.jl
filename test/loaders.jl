# all correct
bindings_df = DataFrame(
    id = ["1", "2", "3"],
    active = [true, false, true],
    scenario = ["scn1", "scn2", "scn3"],
    endpoint = ["A", "B", "C"],
    var"metric.type" = ["mean", "mean", "mean_sd"],
    var"metric.mean" = [1.0, 2.0, 3.0],
    var"metric.sd" = [0.1, 0.2, 0.3],
    var"metric.size" = [100, 200, 300],
)

bindings = parse_metric_bindings(bindings_df)

@test length(bindings) == 3
@test bindings[1].metric isa MeanMetric
@test bindings[2].metric isa MeanMetric
@test bindings[3].metric isa MeanSDMetric

# default active
bindings_df2 = DataFrame(
    id = ["1"],
    scenario = ["scn1"],
    endpoint = ["A"],
    var"metric.type" = ["mean"],
    var"metric.mean" = [1.0],
    var"metric.sd" = [0.1],
    var"metric.size" = [100],
)

bindings2 = parse_metric_bindings(bindings_df2)

@test length(bindings2) == 1
@test bindings2[1].active == true

# parsing error
bindings_df3 = DataFrame(
    id = ["1"],
    scenario = ["scn1"],
    endpoint = ["A"],
    var"metric.type" = ["unknown"],
    var"metric.mean" = [1.0],
    var"metric.sd" = [0.1],
    var"metric.size" = [100],
)

@test_throws ErrorException parse_metric_bindings(bindings_df3)
