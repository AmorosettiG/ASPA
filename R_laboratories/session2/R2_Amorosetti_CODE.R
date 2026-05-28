# R Laboratory Session 2
# Due by : May 26, 2026

# AMOROSETTI Gabriel, 2107530
# Advanced statistics for physics analysis (2025-2026)

##################################################################################

# Loading the dataset, treating first row as colum name
# and we extract the 'x' column as a 1D vector
changepoint_data <- read.csv("assignment2_changepoint_counts.csv")
x <- changepoint_data$x

cat("\nFirst values of the dataset : ")
print(head(x))
# just printing first values of the dataset to check 

# lenght of our data
N <- length(x)

# Defining the prior parameters from the assignment 
alpha <- 1
beta <- 0.1

# and other variables for the first questions (part 1)
n_min <- 5

M <- n_min:(N - n_min) # set of possible change points M (set from n_min to N - n_min)


cat("\nNumber of observations in the dataset (lenght N) : ", N, "\n")


##################################################################################
# (1) Bayesian change-point model

# All the questions of this part are answered on the report


##################################################################################
# (2) Gibbs sampling

# We use the coda library to compute the Effective Sample Size (ESS) later on
library(coda)

### (2.a)

# Defining the Gibbs sampler function
gibbs_sampler <- function(n_iteration, initial_m, init_l1, init_l2, x, alpha, beta) 
{
  
  N <- length(x)
  M <- 5:(N - 5) # definition of the M set, with n_min = 5 
  
  # we follow the hint given in the assignment : recomputing the cumulative sum of x to optimize the update of m 
  S   <- cumsum(x)
  S_N <- S[N]
  
  # Initializing vectors to store our MCMC samples
  samples_m  <- numeric(n_iteration)
  samples_l1 <- numeric(n_iteration)
  samples_l2 <- numeric(n_iteration)
  
  # initial states
  m  <- initial_m
  l1 <- init_l1
  l2 <- init_l2
  
  for (iteration in 1:n_iteration) 
  {

    # The three steps described in the report : 

    # 1 : updating lambda_1 from its Gamma conditional
    S_m <- S[m]
    alpha_1 <- S_m + alpha
    beta_1 <- m + beta
    l1 <- rgamma(1, shape = alpha_1, rate = beta_1)
    
    # 2 : updating lambda_2 from its Gamma conditional
    alpha_2 <- S_N - S_m + alpha
    beta_2 <- N - m + beta
    l2 <- rgamma(1, shape = alpha_2, rate = beta_2)
    
    # 3 : updating m from its discrete conditional, using the log-sum-exp trick
    log_probs <- numeric(length(M))
    for (j in 1:length(M)) 
    {
      k <- M[j]
      S_k <- S[k]
      # calculating the log-probability for a given k
      log_probs[j] <- S_k * log(l1 / l2) - k * (l1 - l2)
    }
    
    # normalizing to prevent numerical underflow or overflow
    max_log_prob <- max(log_probs)
    probs <- exp(log_probs - max_log_prob)
    probs <- probs / sum(probs)
    
    # sampling the new change point m based on the normalized probabilities
    m <- sample(M, size = 1, prob = probs)
    
    # Storing the updated parameters
    samples_m[iteration]  <- m
    samples_l1[iteration] <- l1
    samples_l2[iteration] <- l2
  }
  
  # Returning a data frame with the chain :


  # Adding as first value the initial states before our samples :
  # this makes the chains start exactly at iteration = 0
  return(data.frame(
    m = c(initial_m, samples_m), 
    l1 = c(init_l1, samples_l1), 
    l2 = c(init_l2, samples_l2)
  ))
}
  # OR
  # returning the samples without the inital states :
  # return(data.frame(m = samples_m, l1 = samples_l1, l2 = samples_l2))
# }


### (2.b)

# Then we run 3 chains, with different initial values of m, lamda_1, lambda_2, to verify the convergence
n_iteration <- 5000
set.seed(2107530) # for reproducibility 

cat('\nRunning Gibbs sampler (3 chains with different inital values)\n')
chain1 <- gibbs_sampler(n_iteration, initial_m = 10, init_l1 = 1, init_l2 = 15, x, alpha, beta)
chain2 <- gibbs_sampler(n_iteration, initial_m = 60, init_l1 = 10, init_l2 = 10, x, alpha, beta)
chain3 <- gibbs_sampler(n_iteration, initial_m = 110, init_l1 = 15, init_l2 = 1, x, alpha, beta)


# Plotting the trace plots to check convergence
pdf("trace_plots.pdf", width=8, height=6)
par(mfrow = c(3, 1), mar = c(4, 4, 2, 1))

# Trace for m
plot(chain1$m, type = 'l', col = 'blue', ylab = 'm', xlab = 'Iteration', main = 'Trace plot for m', ylim = range(c(chain1$m, chain2$m, chain3$m)))
lines(chain2$m, col = 'red')
lines(chain3$m, col = 'green')

# Trace for lambda_1
plot(chain1$l1, type = 'l', col = 'blue', ylab = expression(lambda[1]), xlab = 'Iteration', main = expression(bold(paste('Trace plot for ', lambda[1]))), ylim = range(c(chain1$l1, chain2$l1, chain3$l1)))
lines(chain2$l1, col = 'red')
lines(chain3$l1, col = 'green')

# Trace for lambda_2
plot(chain1$l2, type = 'l', col = 'blue', ylab = expression(lambda[2]), xlab = 'Iteration', main = expression(bold(paste('Trace plot for ', lambda[2]))), ylim = range(c(chain1$l2, chain2$l2, chain3$l2)))
lines(chain2$l2, col = 'red')
lines(chain3$l2, col = 'green')

dev.off()


# We zoom in on the first 100 iterations to actually see the chains converging
pdf("trace_plots_zoom.pdf", width=8, height=6)
par(mfrow = c(3, 1), mar = c(4, 4, 2, 1))

# Trace for m
plot(chain1$m, type = 'l', col = 'blue', ylab = 'm', xlab = 'Iteration', main = 'Trace plot for m', xlim = c(1, 100), ylim = range(c(chain1$m, chain2$m, chain3$m)))
lines(chain2$m, col = 'red')
lines(chain3$m, col = 'green')

# Trace for lambda_1
plot(chain1$l1, type = 'l', col = 'blue', ylab = expression(lambda[1]), xlab = 'Iteration', main = expression(bold(paste('Trace plot for ', lambda[1]))), xlim = c(1, 100), ylim = range(c(chain1$l1, chain2$l1, chain3$l1)))
lines(chain2$l1, col = 'red')
lines(chain3$l1, col = 'green')

# Trace for lambda_2
plot(chain1$l2, type = 'l', col = 'blue', ylab = expression(lambda[2]), xlab = 'Iteration', main = expression(bold(paste('Trace plot for ', lambda[2]))), xlim = c(1, 100), ylim = range(c(chain1$l2, chain2$l2, chain3$l2)))
lines(chain2$l2, col = 'red')
lines(chain3$l2, col = 'green')

dev.off()



### (2.c) Burn-in

# Based on the visual inspection of the trace plots, we can see that the chains converge almost instantly
# To be very highly conservative and to ensure that we drop the possible initial correlations, we choose a burn-in of 1000 iterations
burnin <- 1000

# truncating and combining the chains to create our final posterior sample set
valid_chain1 <- chain1[(burnin + 1):n_iteration, ]
valid_chain2 <- chain2[(burnin + 1):n_iteration, ]
valid_chain3 <- chain3[(burnin + 1):n_iteration, ]

posterior <- rbind(valid_chain1, valid_chain2, valid_chain3)


### (2.d) Autocorrelation and Effective Sample Size (ESS)

pdf("acf_plots.pdf", width=8, height=3)
par(mfrow = c(1, 3))
acf(posterior$m, main = "ACF for m")
acf(posterior$l1, main = expression(paste('ACF for ', lambda[1])))
acf(posterior$l2, main = expression(paste('ACF for ', lambda[2])))
dev.off()

# Using the coda package to compute the ESS
ess_m  <- effectiveSize(as.mcmc(posterior$m))
ess_l1 <- effectiveSize(as.mcmc(posterior$l1))
ess_l2 <- effectiveSize(as.mcmc(posterior$l2))

cat('\nEffective Sample Sizes (ESS) : \n')
cat('m        : ', ess_m, '\n')
cat('lambda_1 : ', ess_l1, '\n')
cat('lambda_2 : ', ess_l2, '\n')


### (2.e) Posterior summaries

# Helper function to extract continuous MAP via the density estimation
map_continuous <- function(samples) 
{
  d <- density(samples)
  return(d$x[which.max(d$y)])
}

# For discrete 'm', the MAP is simply the mode (most frequent value)
map_discrete <- function(samples) 
{
  t <- table(samples)
  return(as.numeric(names(t)[which.max(t)]))
}

cat('\n\nPosterior summary :\n')

# m summary
m_mean <- mean(posterior$m)
m_median <- median(posterior$m)
m_sd <- sd(posterior$m)
m_map <- map_discrete(posterior$m)
m_cr <- quantile(posterior$m, probs = c(0.025, 0.975))

cat('\nm : \n Mean =', m_mean, '\n Median =', m_median, '\n SD =', m_sd, '\n MAP =', m_map, '\n 95% CrI = [', m_cr[1], ',', m_cr[2], ']\n\n')

# lambda 1 summary
l1_mean <- mean(posterior$l1)
l1_median <- median(posterior$l1)
l1_sd <- sd(posterior$l1)
l1_map <- map_continuous(posterior$l1)
l1_cr <- quantile(posterior$l1, probs = c(0.025, 0.975))

cat('lambda 1 : \n Mean =', l1_mean, '\n Median =', l1_median, '\n SD =', l1_sd, '\n MAP =', l1_map, '\n 95% CrI = [', l1_cr[1], ',', l1_cr[2], ']\n\n')

# lambda 2 summary
l2_mean <- mean(posterior$l2)
l2_median <- median(posterior$l2)
l2_sd <- sd(posterior$l2)
l2_map <- map_continuous(posterior$l2)
l2_cr <- quantile(posterior$l2, probs = c(0.025, 0.975))

cat('lambda 2 : \n Mean =', l2_mean, '\n Median =', l2_median, '\n SD =', l2_sd, '\n MAP =', l2_map, '\n 95% CrI = [', l2_cr[1], ',', l2_cr[2], ']\n\n')

# Computing correlations
cat('Correlation matrix of the posterior samples : \n')
print(cor(posterior))


# and additional plots of the marginal posterior densities :

pdf("density_plots.pdf", width=8, height=6)
par(mfrow = c(3, 1), mar = c(4, 4, 3, 1))

# Marginal distribution for m (discrete so probability mass function histogram)
m_breaks <- seq(min(posterior$m) - 0.5, max(posterior$m) + 0.5, by = 1)
hist(posterior$m, breaks = m_breaks, prob = TRUE, 
     col = "lightblue", border = "white",
     main = "Marginal posterior mass for m", xlab = "m", ylab = "Probability")
# Adding a line to mark the MAP estimate
abline(v = m_map, col = "darkblue", lwd = 2, lty = 2)

# Marginal density for lambda_1 (continuous so Kernel Density Estimation)
plot(density(posterior$l1), 
     main = expression(paste(bold("Marginal posterior density for "), lambda[1])), 
     xlab = expression(lambda[1]), ylab = "Density", col = "blue", lwd = 2)
# line for MAP
abline(v = l1_map, col = "darkblue", lwd = 2, lty = 2)

# Marginal density for lambda_2 (same)
plot(density(posterior$l2), 
     main = expression(paste(bold("Marginal posterior density for "), lambda[2])), 
     xlab = expression(lambda[2]), ylab = "Density", col = "red", lwd = 2)
# line for MAP
abline(v = l2_map, col = "darkred", lwd = 2, lty = 2)

dev.off()



### (2.f) Posterior probability

# estimation of the probability by counting the fraction of MCMC steps where l2 > l1
prob_l2_greater_l1 <- mean(posterior$l2 > posterior$l1)
cat('\n\nPosterior probability P(lambda_2 > lambda_1 | D) :', prob_l2_greater_l1, '\n')



##################################################################################
# (3) Posterior predictive distribution

### (3.a)
# answered on the report

### (3.b) Estimate posterior predictive mean

# We simulate the new values from the posterior predictive distribution :
# for each sampled lambda_2 from our MCMC, we draw one x_new from a Poisson distribution
set.seed(2107530) # For reproducibility
x_new_simu <- rpois(n = nrow(posterior), lambda = posterior$l2)

# E[x_new | D] is theoretical equivalent to the posterior mean of lambda_2 but simulating it confirms the MCMC validity
predictive_mean_theoretical <- mean(posterior$l2)
predictive_mean_simulated   <- mean(x_new_simu)

cat('\nPosterior predictive mean E[x_new | D] : \n')
cat('Theoretical (mean of lambda_2) : ', predictive_mean_theoretical, '\n')
cat('Simulated (mean of x_new)      : ', predictive_mean_simulated, '\n')


### (3.c) Estimate P(x_new > 2 * x_bar | D)

# calculating the empirical mean of the data
x_bar <- mean(x)
threshold <- 2 * x_bar

# fraction of the simulated predictive values that exceed the threshold
prob_exceed <- mean(x_new_simu > threshold)

cat('\nEmpirical average of data (x_bar)   :', x_bar, '\n')
cat('Threshold (2 * x_bar)               :', threshold, '\n')
cat('Probability P(x_new > 2 * x_bar | D):', prob_exceed, '\n')


### (3.d) Histogram of simulated values

pdf("posterior_predictive_plot.pdf", width=8, height=5)

# to properly plot the discrete int data we offset the breaks by 0.5 so the bars are perfectly centered over the integer values
max_val <- max(max(x_new_simu), ceiling(threshold) + 1)
breaks_seq <- seq(-0.5, max_val + 0.5, by = 1)

hist(x_new_simu, breaks = breaks_seq, prob = TRUE,
     col = "lightgray", border = "white",
     main = "Posterior predictive distribution for next observation",
     xlab = expression(x[new]), ylab = "Probability density")

# x_bar and 2*x_bar lines on the plot
abline(v = x_bar, col = "blue", lwd = 2, lty = 2)
abline(v = threshold, col = "red", lwd = 2, lty = 2)

legend("topright", legend = c(expression(bar(x)), expression(2 * bar(x))),
       col = c("blue", "red"), lwd = 2, lty = 2, bty = "n")

dev.off()


##################################################################################
# (4) Model comparison

### (4.a) and (4.b)
# answered on the report

### (4.c) 

# we compute the exact marginal likelihoods in log-space
# also we drop the common term 1 / prod(x_i!) from both models since it cancels out in the BF ratio

# Recomputing the cumulative sums globally for this section (because it was done but inside the Gibbs sampler function)
S <- cumsum(x)
S_N <- S[N]

# Log marginal likelihood for M0 (no-change model)
log_ev_M0_core <- alpha * log(beta) - lgamma(alpha) + 
                  lgamma(S_N + alpha) - (S_N + alpha) * log(N + beta)

# Log marginal likelihood for M1 (one-change-point model)
log_ev_M1_m_core <- numeric(length(M))

for (j in 1:length(M)) 
{
  m_val <- M[j]
  S_m <- S[m_val]
  
  # Log evidence for a specific m
  log_ev_M1_m_core[j] <- 2 * alpha * log(beta) - 2 * lgamma(alpha) + 
                         lgamma(S_m + alpha) - (S_m + alpha) * log(m_val + beta) + 
                         lgamma(S_N - S_m + alpha) - (S_N - S_m + alpha) * log(N - m_val + beta)
}

# The prior probability for m is 1 / |M| 
log_prior_m <- -log(length(M))

# To sum exp(log_ev_M1_m_core) without overflow, we use the log-sum-exp trick
max_log_ev <- max(log_ev_M1_m_core)
log_sum_exp_term <- max_log_ev + log(sum(exp(log_ev_M1_m_core - max_log_ev)))

# Final log marginal likelihood for M1 :
log_ev_M1_core <- log_prior_m + log_sum_exp_term

# computing log(BF)
log_BF_10 <- log_ev_M1_core - log_ev_M0_core
BF_10 <- exp(log_BF_10)

cat('\nModel Comparison (Log scale) :\n')
cat('Log Evidence M0 (core) :', log_ev_M0_core, '\n')
cat('Log Evidence M1 (core) :', log_ev_M1_core, '\n')
cat('Log Bayes Factor (ln BF_10) :', log_BF_10, '\n')
cat('Bayes Factor (BF_10) :', formatC(BF_10, format = "e", digits = 2), '\n')
# core : ie without the constant term that appears for both models that then cancels out


##################################################################################
# (5) Discussion

# answered on the report
