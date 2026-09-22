# Look at what the covariate did through the **variability**, not the OFV.
# This is the answer to the question Ch 7 left behind.
om <- function(m) {
  b <- fin(m)
  M <- matrix(b[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")], 2)
  c(var.CL = M[1, 1], var.V = M[2, 2], corr = cov2cor(M)[1, 2])
}
tab <- round(rbind(base = om("100base"), weight = om("108wt")), 4)
tab

# How much of the interindividual variability did weight explain?
round(100 * (1 - tab["weight", 1:2] / tab["base", 1:2]), 1)

# Read the exponents too. The theoretical values are CL 0.75 and V 1.0.
round(fin("108wt")[c("THETA5", "THETA6")], 3)
