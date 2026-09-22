# The three thresholds together: chi-square (n infinite), the F threshold of
# Ch 9 (59 subjects, 2 df), and the 95th percentile the permutation gave.
n <- 59; q <- 2
fcut <- n * log(1 + q * qf(0.95, q, n - q) / (n - q))     # from the F distribution of Hotelling's T^2
c(chisq = round(qchisq(0.95, q), 2), F.threshold = round(fcut, 2),
  permutation.95 = round(unname(quantile(null, 0.95)), 2))
