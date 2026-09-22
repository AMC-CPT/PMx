# A model putting interindividual variability on the size of the residual
# (124etaeps). Nothing of the sort was built into these data, so the variance
# ought to go towards 0 and the RSE ought to be large.
e4 <- fin("124etaeps")
c(OFV = round(e4$f[["OBJ"]], 2), dOFV = round(e4$f[["OBJ"]] - b$f[["OBJ"]], 2),
  OM_EPS = signif(e4$f[["OMEGA.4.4."]], 3),
  RSE = round(100 * e4$s[["OMEGA.4.4."]] / e4$f[["OMEGA.4.4."]], 1))
