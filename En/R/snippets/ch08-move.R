# Four changes that alter the fit not at all -- how far do they move the
# condition number?
#   102sig   move the residual error parameters from THETA to SIGMA (same distribution)
#   103mats  covariance estimator S
#   104matr  covariance estimator R
#   105start change only the initial estimates
ofv <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000000, "OBJ"]
}
runs <- c("100base", "102sig", "103mats", "104matr", "105start")
tab <- t(sapply(runs, function(m) c(OFV = ofv(m), blocks(read_cor(m)))))
round(tab, 2)
