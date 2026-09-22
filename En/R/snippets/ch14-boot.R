# The results of 200 resamples (R/boot.R). One row is one resample, and their
# scatter is the parameter uncertainty.
b <- read.csv("nm/boot/boot.csv")
table(termination = b$TERM)

# Each resample has a different number of observations and of distinct people.
# Out of 59, how many on average?
c(mean.obs = round(mean(b$NOBS), 1), min = min(b$NOBS), max = max(b$NOBS),
  people = round(mean(b$NUNIQ), 1), expected = round(59 * (1 - exp(-1)), 1))

# Percentile confidence intervals. Neither normality nor symmetry is assumed.
pars <- c("T1", "T2", "T3", "T4", "T5", "T6", "O11", "O21", "O22")
ci <- t(sapply(b[pars], quantile, c(0.5, 0.025, 0.975), na.rm = TRUE))
colnames(ci) <- c("median", "lower", "upper")
signif(ci, 3)
