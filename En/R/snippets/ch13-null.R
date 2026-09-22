# The result of refitting 200 times on shuffled data (R/rpt.R). Since weight
# carries no information there, the dOFV coming out here is **the size chance
# can produce**.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
ofv <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000000, "OBJ"]
}
base <- ofv("100base")
obs  <- base - ofv("108wt")                  # the dOFV actually obtained

rpt  <- read.csv("nm/rpt/rpt.csv")
null <- base - rpt$OFV[!is.na(rpt$OFV)]

c(actual = round(obs, 2), permutations = length(null),
  null.max = round(max(null), 2), null.median = round(median(null), 2))

# The p value. How often the null distribution produced something as large as
# the actual value (counting itself).
c(p = round((sum(null >= obs) + 1) / (length(null) + 1), 4))

# Compare with the threshold chi-square gives. 2 df (two covariate parameters).
c(chisq.95 = round(qchisq(0.95, 2), 2),
  permutation.95 = round(unname(quantile(null, 0.95)), 2))
