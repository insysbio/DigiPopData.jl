# check PARSERS
@test haskey(PARSERS, "quantile")
@test PARSERS["quantile"] isa Function