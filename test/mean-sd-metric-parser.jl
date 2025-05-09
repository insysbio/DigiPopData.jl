# check PARSERS
@test haskey(PARSERS, "mean_sd")
@test PARSERS["mean_sd"] isa Function
