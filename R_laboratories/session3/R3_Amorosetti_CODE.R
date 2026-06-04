# R Laboratory Session 3
# Due by : June 5, 2026

# AMOROSETTI Gabriel, 2107530
# Advanced statistics for physics analysis (2025-2026)

##################################################################################

library(rjags)
library(coda)

# dataset
logistic_data <- read.csv("logistic_data.csv")
y <- logistic_data$y
x <- logistic_data$x
N <- length(y)

cat("\nN = ", N, "observations in the dataset\n")


##################################################################################
### (1) Posterior formulation and implementation

# defining the JAGS model as a string
# We use JAGS precision (tau = 1/variance = 1/9, here the variance is 3^2 = 9) for the priors

model_string <- "
model {
  for (i in 1:N) {

    # Likelihood
    y[i] ~ dbern(pi[i])
    logit(pi[i]) <- beta0 + beta1 * x[i]
  }

  # priors
  beta0 ~ dnorm(0, 1/9)
  beta1 ~ dnorm(0, 1/9)}
"

# data list for JAGS
jags_data <- list(
  y = y,
  x = x,
  N = N)




### (2) MCMC fitting and diagnostics

cat("\n-------- now running the JAGS model\n")

# 1
# We define different and spaced initial values for the 4 chains
# and we place them in the four quadrants to be sure that the entire parameter space is explored
inits_list <- list(
  list(beta0 = -5, beta1 = -5),
  list(beta0 = 5,  beta1 = 5),
  list(beta0 = -5, beta1 = 5),
  list(beta0 = 5,  beta1 = -5))

# 2
# compiling the JAGS model
# n.adapt = 1000 is used by JAGS to tune the samplers before the actual burn-in
jags_model <- jags.model(
  file = textConnection(model_string),
  data = jags_data,
  inits = inits_list,
  n.chains = 4,
  n.adapt = 1000)

# 3
# burn-in period
# we remove the first 2000 iterations to be sure that the chains have no influence from their starting points
burnin <- 2000
cat("\nburn-in of", burnin, "iterations\n")
update(jags_model, n.iter = burnin)

# 4
# sampling period
# we draw 5000 samples / chain, meaning our final posterior pool will have 20000 valid samples
n_samples <- 5000
cat("sampling of", n_samples, "iterations per chain\n")
posterior_samples <- coda.samples(
  model = jags_model,
  variable.names = c("beta0", "beta1"),
  n.iter = n_samples)

# 5
# diagnostics

cat("\n-------- diagnosticsn")

# Gelman-Rubin diagnostic (R-hat)
# the values close to 1 (strictly < 1.05) indicate that all chains converged to the same distirbution
rhat <- gelman.diag(posterior_samples)
cat("\nGelman-Rubin diagnostic (R-hat) : \n")
print(rhat)

# Effective Sample Size
ess <- effectiveSize(posterior_samples)
cat("\nEffective Sample Sizes (ESS) : \n")
print(ess)

# 6
# diagnostic plots

# trace plots and posterior densities
pdf("mcmc_trace_density_plots.pdf", width=8, height=6)
plot(posterior_samples) # coda default plot manages trace and density automatically
dev.off()

# Autocorrelation plot
pdf("mcmc_acf_plots.pdf", width=8, height=6)
autocorr.plot(posterior_samples)
dev.off()


### (3) Posterior inference

cat("\n-------- Posterior summaries\n")

# 1
# combining the 4 chains into a single matrix of 20 000 samples
samples_matrix <- do.call(rbind, posterior_samples)
b0 <- samples_matrix[, "beta0"]
b1 <- samples_matrix[, "beta1"]

# 2
# summaries for beta0 (the intercept)
cat("\nbeta0 (intercept) : \n")
cat(" Mean    = ", mean(b0), "\n")
cat(" Median  = ", median(b0), "\n")
cat(" SD      = ", sd(b0), "\n")
cat(" 95% CrI = [", quantile(b0, 0.025), ",", quantile(b0, 0.975), "]\n")

# 3
# summaries for beta1 (covariate effect)
cat("\nbeta1 (covariate effect):\n")
cat(" Mean    =", mean(b1), "\n")
cat(" Median  =", median(b1), "\n")
cat(" SD      =", sd(b1), "\n")
cat(" 95% CrI = [", quantile(b1, 0.025), ",", quantile(b1, 0.975), "]\n")

# 4
# computing the posterior correlation
correlation <- cor(b0, b1)
cat("\nPosterior correlation between beta0 and beta1 : ", correlation, "\n")

# 5
# plots

pdf("posterior_inference_plots.pdf", width=11, height=4)
par(mfrow = c(1, 3), mar = c(4, 4, 3, 1))

# marginal density for beta0
plot(density(b0), 
     main = expression(paste("Marginal posterior of ", beta[0])), 
     xlab = expression(beta[0]), ylab = "Density", col = "blue", lwd = 2)
abline(v = mean(b0), col = "darkblue", lty = 2, lwd = 2)

# marginal density for beta1
plot(density(b1), 
     main = expression(paste("Marginal posterior of ", beta[1])), 
     xlab = expression(beta[1]), ylab = "Density", col = "red", lwd = 2)
abline(v = mean(b1), col = "darkred", lty = 2, lwd = 2)

# joint posterior scatter plot
plot(b0, b1, pch = 16, col = rgb(0.1, 0.1, 0.1, 0.05),
     main = expression(paste("Joint posterior ", (beta[0] ~ "," ~ beta[1]))),
     xlab = expression(beta[0]), ylab = expression(beta[1]))

# center of the mass
points(mean(b0), mean(b1), col = "red", pch = 4, cex = 2, lwd = 3)

dev.off()


### (4) Posterior predictive inference

cat("\n-------- Posterior predictive iNference\n")

# 1
# choosing a new covariate value
x_new <- 1.0
cat("Chosen x_new = ", x_new, "\n")

# 2
# computing the posterior draws for pi_new
# using the logistic function: pi = exp(beta0 + beta1 * x) / (1 + exp(beta0 + beta1 * x))
eta_new <- b0 + b1 * x_new
pi_new  <- exp(eta_new) / (1 + exp(eta_new))

# summaries for pi_new
cat("\nPosterior summaries for pi_new = P(y_new = 1 | x_new, beta0, beta1) :\n")
cat(" Mean    = ", mean(pi_new), "\n")
cat(" Median  = ", median(pi_new), "\n")
cat(" SD      = ", sd(pi_new), "\n")
cat(" 95% CrI = [", quantile(pi_new, 0.025), ",", quantile(pi_new, 0.975), "]\n")

# 3
# simulating the posterior predictive draws for y_new
# for each sampled probability pi_new, we draw exactly one Bernoulli trial (of size = 1)

set.seed(2107530) # for reproducibility
y_new_sim <- rbinom(n = length(pi_new), size = 1, prob = pi_new)

# posterior predictive probability P(y_new = 1 | x_new, D)
prob_y_new_1 <- mean(y_new_sim)
cat("\nPosterior predictive probability P(y_new = 1 | x_new, D) : ", prob_y_new_1, "\n")
# law of total expectation => this is equivalent to mean(pi_new), but we simulate it explicitly so it proves the generative process

# 4
# plotting the histogram/density of pi_new
pdf("posterior_predictive_pi_new.pdf", width=7, height=5)
hist(pi_new, breaks=50, prob=TRUE, col="lightblue", border="white",
     main=bquote("Posterior distribution of " ~ pi[new] ~ " for " ~ x[new] == .(x_new)),
     xlab=expression(pi[new]), ylab="Probability density")
lines(density(pi_new), col="darkblue", lwd=2)
abline(v=mean(pi_new), col="red", lwd=2, lty=2)

legend("topleft", legend=c("Density KDE", "Mean"), 
       col=c("darkblue", "red"), lwd=2, lty=c(1, 2), bty="n")
dev.off()




### (5) Model comparison

cat("\n-------- model comparison (DIC)\n")

# 1
# definiton of the M0 model (intercept-only) as a string
# --> we drop beta1 totally 

model_string_m0 <- "
model {
  for (i in 1:N) {
    y[i] ~ dbern(pi[i])
    logit(pi[i]) <- beta0
  }
  
  # Prior (using precision tau = 1/9)
  beta0 ~ dnorm(0, 1/9)}
"

# 2
# initializing and compiling M0
inits_list_m0 <- list(
  list(beta0 = -5),
  list(beta0 = 5),
  list(beta0 = -2),
  list(beta0 = 2))

jags_model_m0 <- jags.model(
  file = textConnection(model_string_m0),
  data = jags_data,
  inits = inits_list_m0,
  n.chains = 4,
  n.adapt = 1000)

# M0 burn-in
cat("\nM0 burn-in\n")
update(jags_model_m0, n.iter = 2000)

# 3
# computing DIC for the 2 models
# we use dic.samples() which is native in the rjags library
n_dic_samples <- 5000

cat("\nComputing DIC for M0 (intercept-only)\n")
dic_m0 <- dic.samples(jags_model_m0, n.iter = n_dic_samples)

cat("Computing DIC for M1 (full model with covariate x)\n")
# 'jags_model' is the original M1 model we compiled in the question 2
dic_m1 <- dic.samples(jags_model, n.iter = n_dic_samples)

# 4
# results

cat("\n-------- DIC results\n")
cat("Model M0 (intercept-only) : \n")
print(dic_m0)

cat("\nModel M1 (full model) : \n")
print(dic_m1)

# difference (M1 - M0)
cat("\ndifference in DIC : \n")
diff_dic <- diffdic(dic_m1, dic_m0)
print(diff_dic)
