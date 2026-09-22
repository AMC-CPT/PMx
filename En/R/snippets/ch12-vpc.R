# VPC. See whether the observations lie inside the distribution of simulated
# concentrations.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
sim <- read.csv(nmf("108wtsim", "simtab.csv"))          # 200 replicates x 155 observations
obs <- read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)
obs <- obs[obs$MDV == 0, ]
c(replicates = length(unique(sim$REP)), observations = nrow(obs))

# Cut the time bins at quantiles so that the observations divide evenly.
brk <- unique(quantile(obs$TIME, seq(0, 1, length.out = 7)))
mid <- function(t) tapply(t, cut(t, brk, include.lowest = TRUE), median)
obs$BIN <- cut(obs$TIME, brk, include.lowest = TRUE)
sim$BIN <- cut(sim$TIME, brk, include.lowest = TRUE)

# The observed quantiles, and the quantiles of the per-replicate quantiles
# (the confidence band)
qs <- c(0.05, 0.5, 0.95)
oq <- sapply(qs, function(q) tapply(obs$DV, obs$BIN, quantile, q))
sq <- sapply(qs, function(q) {
  m <- tapply(seq_len(nrow(sim)), list(sim$BIN, sim$REP),
              function(i) quantile(sim$DV[i], q))
  t(apply(m, 1, quantile, c(0.025, 0.5, 0.975), na.rm = TRUE))
}, simplify = "array")
round(oq, 1)
