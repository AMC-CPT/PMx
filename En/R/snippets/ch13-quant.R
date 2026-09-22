# A permutation test assumes no chi-square. So the other way round, it can test
# whether the chi-square approximation holds. Put them side by side quantile by
# quantile.
pr <- c(0.5, 0.8, 0.9, 0.95, 0.99)
round(rbind(permutation = quantile(null, pr), chisq = qchisq(pr, 2)), 2)

# The tails, though, are different.
c(null.max = round(max(null), 2), `above 10` = sum(null > 10),
  `above 20` = sum(null > 20))
