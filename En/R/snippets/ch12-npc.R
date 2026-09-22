# NPC is the numerical version of the VPC. Instead of a figure it counts the
# **coverage**: what percentage of observations falls inside the 90 % prediction
# interval of the simulated distribution. 90 is good.
cover <- function(p) {
  lo <- (1 - p) / 2; hi <- 1 - lo
  q <- t(sapply(seq_len(nrow(obs)), function(i) {
    v <- sim$DV[sim$ID == obs$ID[i] & sim$TIME == obs$TIME[i]]
    quantile(v, c(lo, hi))
  }))
  inside <- obs$DV >= q[, 1] & obs$DV <= q[, 2]
  c(expected = 100 * p, actual = round(100 * mean(inside), 1),
    below = round(100 * mean(obs$DV < q[, 1]), 1),
    above = round(100 * mean(obs$DV > q[, 2]), 1))
}
t(sapply(c(0.5, 0.8, 0.9, 0.95), cover))
