<div align="center">
  <h2>R Laboratory - Session 3</h2>
</div>

You will analyze a simulated binary-response dataset using Bayesian Bernoulli regression. The data consist of observations

$$D=\{(y_{i},x_{i})\}_{i=1}^{N}\quad(1)$$

where $y_{i}\in\{0,1\}$ is a binary outcome and $x_{i}$ is a real-valued explanatory variable.

In this assignment you will fit Bayesian logistic regression models using either JAGS or Stan. You are expected to run multiple chains, diagnose convergence and mixing, and justify the reliability of your posterior summaries.

### Model
The main model is

$$y_{i}|\beta_{0},\beta_{1}\sim Bernoulli(\pi_{i}),\quad(2)$$
$$logit(\pi_{i})=\beta_{0}+\beta_{1}x_{i},\quad(3)$$

with independent priors

$$\beta_{0}\sim\mathcal{N}(0,3^{2}),\quad(4)$$
$$\beta_{1}\sim\mathcal{N}(0,3^{2}).\quad(5)$$

Equivalently,

$$\pi_{i}=\frac{exp(\beta_{0}+\beta_{1}x_{i})}{1+exp(\beta_{0}+\beta_{1}x_{i})}.\quad(6)$$

### Tasks

**(1) Posterior formulation and implementation.** Then implement the logistic Bernoulli regression model in JAGS or Stan. Include the model code in your submission and clearly state which software and interface you used.

**(2) MCMC fitting and diagnostics.** Run at least four MCMC chains from dispersed initial values. Use a sufficiently long warm-up/burn-in period and sampling period. Report and discuss the main convergence and mixing diagnostics, including trace plots, $\hat{R},$ effective sample size, and autocorrelation. If using Stan, also report whether there were divergent transitions and comment on any relevant sampler diagnostics. If using JAGS, comment on burn-in, thinning if used, and chain mixing.

**(3) Posterior inference.** Report posterior summaries for $\beta_{0}$ and $\beta_{1}$: posterior mean, median, standard deviation, and 95% credible interval. Plot the marginal posterior distributions and the joint posterior samples in the $(\beta_{0},\beta_{1})$ plane. Comment on the sign, magnitude, and uncertainty of the covariate effect, the posterior correlation between the two regression coefficients.

**(4) Posterior predictive inference.** For a new covariate value $x_{new}$, use posterior simulation to approximate the posterior predictive distribution

$$p(y_{new}|x_{new},D).\quad(7)$$

State the value of $x_{new}$ you use. Report the posterior mean and 95% credible interval for

$$\pi_{new}=P(y_{new}=1|x_{new},\beta_{0},\beta_{1}).\quad(8)$$

and report the posterior predictive probability

$$P(y_{new}=1|x_{new},D).$$

Produce a histogram or density plot of posterior draws of $\pi_{new}.$

**(5) Model comparison.** Fit the intercept-only model

$$M_{0}:logit(\pi_{i})=\beta_{0},\quad(9)$$
$$\beta_{0}\sim\mathcal{N}(0,3^{2})\quad(10)$$

and compare it with the full model

$$M_{1}:logit(\pi_{i})=\beta_{0}+\beta_{1}x_{i}.\quad(11)$$

Use an appropriate Bayesian model-comparison criterion available from your chosen workflow. Interpret which model is better supported by the data and whether the covariate $x_{i}$ improves predictive performance.

**(6) Discussion.** Briefly summarize your conclusions. Your discussion should address whether the chains appear to have converged, whether the posterior uncertainty is substantial, whether the covariate effect is credibly different from zero, whether the posterior predictive probabilities are compatible with the observed data, and which model you prefer.
