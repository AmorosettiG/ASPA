<div align="center">
  <h2>R Laboratory - Session 1</h2>
</div>

You are given a dataset of integer-valued observations (see attached file)
$$D=\{x_{1},x_{2},...,x_{N}\}, \quad (1)$$
representing the number of events observed in identical time intervals. Analyze the data using the Bayesian framework following the subsequent points.

**(1)** Assume that the data are generated from a Poisson distribution:
$$x_{i}\sim Poisson(\lambda) \quad (2)$$
with a Gamma prior on $\lambda$:
$$\lambda\sim Gamma(\alpha,\beta) \quad (3)$$

* **(1.a)** Derive the posterior distribution $p(\lambda|D)$.
* **(1.b)** Compute the maximum a posteriori (MAP) estimate of $\lambda$.
* **(1.c)** Discuss whether the posterior is approximately symmetric for the given dataset, and provide an adequate estimate of the uncertainty on $\lambda$.

**(2)** Using the above Poisson model:

* **(2.a)** Derive the posterior predictive distribution for a new observation $x_{new}.$
* **(2.b)** Compute the probability that the next observation exceeds twice the empirical average $\overline{x}$:
$$P(x_{new}>2\overline{x}) \quad (4)$$

**(3)** Consider now an alternative model with a Negative Binomial distribution for the data.
$$x_{i}\sim NegBin(r,\pi), \quad (5)$$
where $r>0$ and $0<\pi<1$ are the model parameters.

* **(3.1)** Give the posterior distribution $p(r,\pi|D)$ motivating your choice of prior distribution.
* **(3.2)** Assuming a Gaussian shape of the posterior, give a point estimate of the parameters $r$ and $\pi$ via MAP estimation and its associated error.
* **(3.3)** Under the same assumption, compute the evidence of the Negative Binomial model.
* **(3.4)** Compare this result with the evidence obtained for the Poisson model by computing the Bayes factor:
$$BF=\frac{p(D|M_{NB})}{p(D|M_{Poisson})} \quad (6)$$

**(4) Discussion:** Which model is favored and to which degree? Is this unexpected?

*Hint: Graphically compare the posterior distributions when necessary, to substantiate your choices and approximations.*
