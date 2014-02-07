# ZVSimulator

[![Build Status](https://travis-ci.org/scidom/ZVSimulator.jl.png)](https://travis-ci.org/scidom/ZVSimulator.jl)

The `ZVSimulator` package provides a framework for assessing the zero variance (ZV) principle for Monte Carlo or
random sampling via simulation.

#### Package Overview

The `ZVSimulator` is used for assessing the effectiveness of the zero variance principle on arbitrary MCMC samplers
or on arbitrary univariate or multivariate distributions. The simulation-based evaluation of ZV's effectiveness is
made by estimating the variance reduction factor (VRF), which is the ratio of the variance of the original estimator
over the variance of the ZV estimator.

To compute the variance of the original estimator of a summary statistic, several Monte Carlo chains are simulated from
a given MCMC sampler or several sets of independently and identically distributed (i.i.d.) samples are randomly drawn
from a given distribution. Then the summary statistic (typically the mean) is computed for each chain or for each sample
set and the sample variance of these summary statistics (typically the sample variance of these means) is computed. This
way the variance of the original estimator for a given summary statistic is computed. The value of the score function,
that is the value of the gradient of the log-likelihood, along the chain iterations or along the i.i.d. samples is
stored and is employed in order to calculate the corresponding ZV estimator.

#### Features

The main features of the `ZVSimulator` from the user's perspective are the following:
- Integrated usage with the `Distributions` and `MCMC` packages. The user can define distributions or MCMC tasks by
using the standard interface of `Distributions` or `MCMC`, so as to pass them to the `ZVSimulator`.
- Minimal effort to set up a ZV simulation due to the high level interface with `Distributions` and `MCMC`. This
facilitates shifting the user's focus from programming towards the statistical issue of ZV's effectiveness. For
example, the gradient computation is done by using the relevant score functions defined in `Distributions` and the
ZV coefficients are calculated using the relevant ZV functions in `MCMC`.
- Assessment of ZV for any summary statistic by passing a function that transforms the simulated samples.
- Lower level functionality, which allows assessing ZV for any user-defined random process leaving room for future
developments of ZV on more stochastic models.
- Parallel implementation of the `ZVSimulator`, which provides faster computations on several workers.

#### Examples

##### ZV for a univariate distribution

As an example of how one can compute the VRFs for a univariate distribution, consider a t-distribution with 5 degrees
of freedom. The distribution is defined by calling `TDist(5.)` using the relevant constructor from `Distributions`.
Then the `psim_rand_vrf()` function is invoked on the t-density, from which 100 sample sets are drawn, each of size
1000. Note that if julia is started by `julia -p 4` for instance, then the simulation will run on 4 workers on the
local machine. The code for this example is the following and can also be found in `examples/rand_tdist.jl`:

```
using Distributions, ZVSimulator

d = TDist(5.)

results = psim_rand_vrf(d, nsets=100, nsamples=1000)
```

##### ZV for MCMC

`examples/mcmc_mvtdist.jl` provides an example of computing the VRFs for a Monte Carlo simulation from a multivariate
Student target distribution. The MCMC tasks are defined by using the (model, sampler, runner) triplet-interface of
the `MCMC` package. Then `psim_serialmc_vrf()` is invoked on these tasks to calculate the VRFs by simulating 100 chains,
each consisting of 10000 iterations of which the first 1000 are discarded as burnin.

```
using Distributions, MCMC, ZVSimulator

function C(n::Int, c::Float64)
  X = eye(n)
  [(j <= n-i) ? X[i+j, i] = X[i, i+j] = c^j : nothing for i = 1:(n-1), j = 1:(n-1)]
  X
end

df, npars, a = 5., 4, 0.25
c = ((df-2)/df)*C(npars, a)

mcmodel = model(MvTDist(df, zeros(npars), c), init=zeros(npars))
samplers = [HMCDA() for i in 1:100]
tasks = mcmodel * samplers * SerialMC(steps=10000, burnin=1000)

results = psim_serialmc_vrf(tasks)
```
