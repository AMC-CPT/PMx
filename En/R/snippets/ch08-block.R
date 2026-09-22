# One overall condition number does not say which parameter is the trouble.
# Split it into blocks. The criterion is the **statistical role**, not whether
# something is a THETA or an OMEGA.
#   structure: typical PK parameters and covariate coefficients (THETA1, THETA2)
#   variability: OMEGA, SIGMA, and the residual error parameters kept in THETA
blocks <- function(C) {
  st <- c("THETA1", "THETA2")
  va <- setdiff(rownames(C), st)
  th <- grep("^THETA", rownames(C), value = TRUE)
  c(overall = kap(C), structure = kap(C[st, st]), variability = kap(C[va, va]),
    THETA.block = kap(C[th, th]))
}
round(blocks(C), 2)
