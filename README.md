# DigiPopData.jl
Data prep and visualization tools for Virtual Patient QSP modeling

## Overview

DigiPopData.jl is a Julia package designed to facilitate the preparation and visualization of data for Virtual Patient QSP (Quantitative Systems Pharmacology) modeling. It provides a set of tools and functions to streamline the process of data handling, making it easier for researchers and practitioners in the field of pharmacometrics and systems biology.

The package provides the unified table format for the real population data, divided to different metrics types. The data can be loaded from DataFrame or CSV file.

It also expect the specific format for the virtual population data, which is a DataFrame.

## Implemented metrics

Each metric compare real and virtual populations base on the following statistics:

- `Mean` - compare the mean
- `MeanSD` - compare the mean and standard deviation
- `Category` - compare the categorical distribution
- `Quantile` - compare the quantile values
- `Survival` - compare the survival curves

## Code example

```julia
using DigiPopData

# create metric based on Survival data
metric1 = RealMetricSurvival(
    150,    # number of patients in the real population
    [0.8111, 0.3480, 0.2852, 0.2538, 0.2307, 0.2307, 0.1818, 0.1338], # survival values in descending order
    [2., 5., 8., 10., 12., 15., 20., 25.] # time points
)

# calculate loss function for data on metric -2ln(Likelihood)
loss_value = mismatch(
    [2., 1.4, 4.4, 6., 7.89], # individual survival times for 5 patients
    metric1
)

# connect metric to the virtual population endpoints
# can be used for the loss function calculation based on simulated endpoints
binding1 = MetricBinding(
    "Point1", # unique identifier for the binding
    "scn1",   # reference to simulation scenario
    metric1,  # connected metric
    "TTE",    # name of endpoint (variable) in virtual individual point
    true      # if false, the metric has no input to loss function
)
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

Copyright (c) 2025 InSysBio CY
