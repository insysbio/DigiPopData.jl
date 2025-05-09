# correct input
m1 = QuantileMetric(100, [0.5], [10.])

@test m1.group_active == [true, true] # all groups are active
@test all(m1.cov_inv .== [4.;;])
@test m1.skip_nan == false

@test isapprox(mismatch([1., 2., 3., 11., 12., 13.], m1), 0.)
@test isapprox(mismatch([-Inf, 2., 3., 11., 12., Inf], m1), 0.)
@test isapprox(mismatch([1., 2., 3., 4., 5., 6.], m1), 36.)
@test_throws ArgumentError mismatch([1., 2., 3., 4., 5., 6., NaN], m1)
@test_throws ArgumentError mismatch(Float64[], m1)

# correct input skip_nan = true
m2 = QuantileMetric(100, [0.25, 0.5, 0.75], [1., 10., 100.], true)

@test m2.group_active == [true, true, true, true] # all groups are active
@test all(m2.cov_inv .== [8. 4. 4.; 4. 8. 4.; 4. 4. 8.])
@test m2.skip_nan == true

@test isapprox(mismatch([0., 5., 50., 500.], m2), 0.)
@test isapprox(mismatch([0., 5., 50., 500., NaN, NaN], m2), 12.)
@test_throws ArgumentError mismatch([NaN, NaN, NaN], m1)
@test_throws ArgumentError mismatch(Float64[], m1)

# correct input duplicate levels
m3 = QuantileMetric(100, [0.25, 0.5, 0.5, 0.75], [1., 10., 20., 100.])

@test m3.group_active == [true, true, false, true, true]
@test all(m3.cov_inv .== [8. 4. 4.; 4. 8. 4.; 4. 4. 8.])
@test m3.skip_nan == false

# incorrect metric
@test_throws ArgumentError QuantileMetric(100, [0.5, 0.3, -0.2], [1., 10., 100.]) # negative rate
@test_throws ArgumentError QuantileMetric(100, [0.5, 0.3, 0.1], [1., 10., 100.]) # not ascenting
@test_throws ArgumentError QuantileMetric(100, [0.1, 0.5, 0.9], [10., 1., 20.]) # not ascenting
@test_throws ArgumentError QuantileMetric(100, [0.5, 0.3, 0.1], [1., 10., NaN]) # NaN rate
@test_throws DimensionMismatch QuantileMetric(100, [0.5, 0.3, 0.1], [1., 10., 100., 1000.]) # wromg length
@test_throws ArgumentError QuantileMetric(100, Float64[], Float64[]) # empty

# mismatch_expression tests
model = JuMP.Model()
@variable(model, X[1:101], Bin)
m4 = QuantileMetric(100, [0.5], [10.])
simulated_data = [fill(5., 50); fill(15., 50); 20.]
expr1 = mismatch_expression(simulated_data, m4, X, 10)

@test expr1 isa QuadExpr

@test_throws DimensionMismatch mismatch_expression(simulated_data, m4, X, 500) # too long X_len

simulated_data = [fill(5., 50); fill(15., 50)]
@test_throws DimensionMismatch mismatch_expression(simulated_data, m4, X, 10) # length of sim and X are not equal