# check PARSERS
@test haskey(PARSERS, "mean")
@test PARSERS["mean"] isa Function

