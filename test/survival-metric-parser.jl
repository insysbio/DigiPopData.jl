# check PARSERS
@test haskey(PARSERS, "survival")
@test PARSERS["survival"] isa Function