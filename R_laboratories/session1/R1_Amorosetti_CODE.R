# R Laboratory Session 1
# Due by : April 28, 2026

# AMOROSETTI Gabriel, 2107530
# Advanced statistics for physics analysis (2025-2026)

##################################################################################

# Loading the dataset, not treating first row as colum name, 
# and extracting the first (only) column as a 1D vector
data <- read.table("dataset.txt", header = FALSE)$V1


# Computing some statistics about our data that we need for next questions

N <- length(data)
sum_data <- sum(data)
mean_data <- sum_data / N
var_data <- var(data)

######### (1)

# We can assign prior parameters for Gamma(alpha, beta)
alpha_prior <- 1
beta_prior  <- 0.01    # Using weakly informative prior parameters as no specific values were given

### (1.a)
# answered on the report

# We now have : 
alpha_post <- alpha_prior + sum_data
beta_post <- beta_prior + N
cat("\n\n", "alpha_post :", alpha_post)
cat("\n",   "beta_post :" ,  beta_post,  "\n")


#### (1.b)

lambda_map <- (alpha_post - 1) / beta_post
cat("\n", "lambda MAP estimate :", lambda_map, '\n')


#### (1.c)

skewness <- 2 / sqrt(alpha_post)
cat('\n', "skewness of the Gamma posterior : ", skewness)

lambda_uncertainty <- sqrt(alpha_post) / beta_post
cat('\n', "uncertainty on lambda :", lambda_uncertainty, "\n")


######### (2)

### (2.a)
# answered on the report

### (2.b)

# we want P(x_new > 2 * mean_data)
threshold <- 2 * mean_data

# predictive distribution is the negative binomial : NegBin(alpha_post, beta_post/(beta_post+1))
# In R's pnbinom, size = alpha_post, prob = beta_post / (beta_post + 1)
prob_success <- beta_post / (beta_post + 1)

# P(X > threshold) = 1 - P(X <= threshold)
# we use floor() because the negative binomial is discrete (defined on integers)
prob_exceed <- 1 - pnbinom(q = floor(threshold), size = alpha_post, prob = prob_success)
cat('\n', "P(x_new > 2 * mean) : ", prob_exceed, "\n")


######### (3)

### (3.1)
# answered on the report

### (3.2)

# negative log-posterior function
neg_log_posterior <- function(params, data) {
  r <- params[1]
  pi <- params[2]
  
  ll <- sum(dnbinom(data, size = r, prob = pi, log = TRUE))   # log-likelihood
  
  # log-priors
  log_prior_r <- -log(r) 
  log_prior_pi <- 0
  
  return(-(ll + log_prior_r + log_prior_pi))
}

# initial guesses :
# we need the empirical variance to have a good initial guess for the optimization
pi_init <- mean_data / var_data
r_init <- mean_data^2 / (var_data - mean_data)

# now optimizing
opt <- optim(par = c(r_init, pi_init), 
             fn = neg_log_posterior, 
             data = data, 
             method = "L-BFGS-B",
             lower = c(0.001, 0.001), 
             upper = c(Inf, 0.999),
             hessian = TRUE)

r_map <- opt$par[1]
pi_map <- opt$par[2]


cat("\n", "MAP of r : " , r_map)
cat("\n", "MAP of pi : ", pi_map)

# we get the coviarance by the inverse of the hessian
cov_matrix <- solve(opt$hessian)
cat("\n", "Errors (Standard deviations on original parameters) :\n")
print(sqrt(diag(cov_matrix)))

### (3.3)

d <- 2
neg_log_post_MAP <- opt$value
log_det_H <- determinant(opt$hessian, logarithm = TRUE)$modulus
log_evidence_NB <- -neg_log_post_MAP + (d/2)*log(2*pi) - 0.5*log_det_H
cat("\nLog-evidence for the negative binomial model :", log_evidence_NB, "\n")

### (3.4)

# computing the exact log-evidence for the Poisson model
# ie the integral of (Poisson likelihood * Gamma prior) over lambda
log_ev_pois_exact <- sum(-lgamma(data + 1)) + 
                     alpha_prior*log(beta_prior) - lgamma(alpha_prior) + 
                     lgamma(alpha_post) - alpha_post*log(beta_post)

cat("Log-evidence for Poisson model : ", log_ev_pois_exact, "\n")

# Bayes factor (in log scale)
log_BF <- log_evidence_NB - log_ev_pois_exact
cat("Log Bayes factor (ln BF) :", log_BF, "\n\n")


######### (4)

pdf("posterior_plot.pdf", width=8, height=5) # saving the plot

x_range <- 0:max(data)
poisson_y <- dnbinom(x_range, size=alpha_post, prob=prob_success)
negbin_y <- dnbinom(x_range, size=r_map, prob=pi_map)

# to avoid line cut 
max_y <- max(max(poisson_y), max(negbin_y)) * 1.1

# data histogram    
hist(data, breaks=seq(-0.5, max(data)+0.5, by=1), prob=TRUE, 
     main="Model comparison : Poisson vs negative binomial", 
     xlab="Number of events observed", col="lightgray", border="white", 
     ylim=c(0, max_y))

# Poisson model
lines(x_range, poisson_y, type="b", col="blue", pch=16, lwd=2)

# negative binomial MAP
lines(x_range, negbin_y, type="b", col="red", pch=17, lwd=2)

legend("topright", legend=c("Data histogram", "Poiss    on model", "Negative binomial model"), 
       col=c("lightgray", "blue", "red"), pch=c(15, 16, 17), pt.cex=1.5, bty="n")

dev.off()


