<div align="center">
  <h2>R Laboratory - Session 2</h2>
</div>

You are given a dataset of integer-valued observations,
$$D=\{x_{1},x_{2},...,x_{N}\}, \tag{1}$$
contained in the file `assignment2_changepoint_counts.csv`. The data represent the number of events observed in identical consecutive time intervals. In this assignment, the order of the observations matters.

The goal is to analyze the data using Markov chain Monte Carlo methods. All MCMC algorithms must be coded directly in R. Do not use JAGS, Stan, NIMBLE, brms, rstanarm, or other automatic Bayesian sampling software that have not yet been covered in the lectures.

Throughout the assignment, use the Gamma density parameterized by shape and rate. 
$$p(\lambda|\alpha,\beta)=\frac{\beta^{\alpha}}{\Gamma(\alpha)}\lambda^{\alpha-1}e^{-\beta\lambda}, \quad \lambda>0 \tag{2}$$

Unless otherwise stated, use
$$\alpha=1, \quad \beta=0.1 \tag{3}$$

### (1) Bayesian change-point model

Assume that the data are generated from a Poisson model with one unknown *change point*. Before the change point, the event rate is $\lambda_{1}$; after the change point, the event rate is $\lambda_{2}$. More precisely,
$$x_{i}|\lambda_{1},m\sim Poisson(\lambda_{1}), \quad i=1,...,m \tag{4}$$
$$x_{i}|\lambda_{2},m\sim Poisson(\lambda_{2}), \quad i=m+1,...,N \tag{5}$$
where
$$m\in\mathcal{M}=\{n_{min},n_{min}+1,...,N-n_{min}\}, \quad \text{with } n_{min}=5 \tag{6}$$

Take the prior distributions as
$$\lambda_{1}\sim Gamma(\alpha,\beta) \tag{7}$$
$$\lambda_{2}\sim Gamma(\alpha,\beta) \tag{8}$$
$$m\sim Unif(\mathcal{M}) \tag{9}$$

**(1.a)** Write the likelihood
$$p(D|\lambda_{1},\lambda_{2},m) \tag{10}$$

**(1.b)** Write the posterior distribution
$$p(\lambda_{1},\lambda_{2},m|D)$$
up to a proportionality constant.

**(1.c)** Define the cumulative sums
$$S_{m}=\sum_{i=1}^{m}x_{i}; \quad S_{N}=\sum_{i=1}^{N}x_{i}. \tag{11}$$
Show that, conditionally on $m$, the posterior distributions of the two rates are Gamma distributions. Give their parameters.

**(1.d)** Derive the conditional posterior distribution
$$p(m|\lambda_{1},\lambda_{2},D) \tag{12}$$
Explain why it is a discrete distribution over $\mathcal{M}$.

**(1.e)** Explain why this model is a natural case for MCMC, even though some conditional distributions are available analytically.

### (2) Gibbs sampling

Implement a Gibbs sampler for $(\lambda_{1},\lambda_{2},m)$.

**(2.a)** Write explicitly the three update steps of one Gibbs iteration. In the update of $m$, compute the probabilities on the log scale and normalize them carefully.

**(2.b)** Run at least three chains, starting from different initial values of $m$, $\lambda_{1}$ and $\lambda_{2}$. Produce trace plots for $\lambda_{1}$, $\lambda_{2}$, and $m$.

**(2.c)** Decide on an appropriate burn-in period and justify your choice.

**(2.d)** Plot the autocorrelation function for $\lambda_{1}$, $\lambda_{2}$, and $m$. Estimate the effective sample size for $\lambda_{1}$, $\lambda_{2}$, and $m$.

**(2.e)** Report posterior summaries for $\lambda_{1}$, $\lambda_{2}$, and $m$: posterior mean, posterior median, posterior standard deviation, MAP estimate, and a 95% credible interval.

**(2.f)** Estimate the posterior probability
$$P(\lambda_{2}>\lambda_{1}|D). \tag{13}$$
Interpret the result.

### (3) Posterior predictive distribution

Let $x_{new}$ be the number of events observed in the next time interval, after the end of the dataset.

**(3.a)** Write the posterior predictive distribution
$$p(x_{new}|D) \tag{14}$$
as an integral and sum over the posterior distribution of the unknown parameters. Explain why, for a future observation after time $N$, the relevant rate is $\lambda_{2}$.

**(3.b)** Using your Gibbs sampler output, estimate the posterior predictive mean
$$\mathbb{E}[x_{new}|D]. \tag{15}$$

**(3.c)** Using your Gibbs sampler output, estimate
$$\mathbb{P}(x_{new}>2\overline{x}|D), \tag{16}$$
where
$$\overline{x}=\frac{1}{N}\sum_{i=1}^{N}x_{i}. \tag{17}$$

**(3.d)** Produce a histogram of simulated values from the posterior predictive distribution and mark $\overline{x}$ and $2\overline{x}$ on the plot.

### (4) Model comparison

Compare the one-change-point model $M_{1}$ with the simpler no-change model $M_{0}$ :
$$M_{0}: \quad x_{i}|\lambda\sim Poisson(\lambda), \quad i=1,...,N, \tag{18}$$
with the same prior $\lambda\sim Gamma(\alpha,\beta)$.

**(4.a)** Derive the marginal likelihood $p(D|M_{0})$. You may ignore factors that are common to both models when computing the Bayes factor.

**(4.b)** Derive the marginal likelihood $p(D|M_{1})$ by summing over $m\in\mathcal{M}$ and integrating over $\lambda_{1}$ and $\lambda_{2}$.

**(4.c)** Compute the Bayes factor
$$BF_{10}=\frac{p(D|M_{1})}{p(D|M_{0})} \tag{19}$$
and interpret the result. Which model is favored, and to which degree?

### (5) Discussion

Shortly summarize your conclusions. Your discussion should address in a precise but concise way the following points:

* Is there evidence for a change point in the event rate?
* What is the most plausible location of the change point?
* Are the two rates clearly separated according to the posterior distribution?
* Did the different chains give consistent results?
* How large are the autocorrelations? How reliable are the effective sample sizes?
* The model contains a discrete parameter $m$. Explain why Hamiltonian Monte Carlo cannot be applied directly to the full state $(\lambda_{1},\lambda_{2},m)$ without modifying the model or marginalizing over $m$.

**Hint:** Use cumulative sums $S_{m}$ to make the computation efficient. When normalizing discrete probabilities over $m$, use log-probabilities and possibly subtract the maximum log-probability before exponentiating.
