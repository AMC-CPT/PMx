# Contrast with the Wald test: the estimate divided by its standard error,
# referred to a normal distribution.
fin <- function(m, it = -1000000000) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == it, -1])
}
est <- fin("108wt"); se <- fin("108wt", -1000000001)

wald <- function(k, h0) {
  z <- (est[[k]] - h0) / se[[k]]
  c(estimate = round(est[[k]], 3), SE = round(se[[k]], 3), z = round(z, 2),
    p = signif(2 * pnorm(-abs(z)), 3))
}
rbind(`WT~CL (h0=0)` = wald("THETA5", 0), `WT~V (h0=0)` = wald("THETA6", 0))
