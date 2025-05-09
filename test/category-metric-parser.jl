# check PARSERS
@test haskey(PARSERS, "category")
@test PARSERS["category"] isa Function