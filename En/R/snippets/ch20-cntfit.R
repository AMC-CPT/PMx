# Poisson (cnt100), negative binomial (cnt101), negative binomial with no drug
# effect (cnt102).
c0 <- fin("cnt100"); c1 <- fin("cnt101"); c2 <- fin("cnt102")
data.frame(
  model = c("Poisson + effect", "neg. binomial + effect", "neg. binomial, no effect"),
  OFV = round(c(c0$f[["OBJ"]], c1$f[["OBJ"]], c2$f[["OBJ"]]), 1),
  LAM0 = signif(c(c0$f[["THETA1"]], c1$f[["THETA1"]], c2$f[["THETA1"]]), 3),
  EMAX = c(signif(c0$f[["THETA2"]], 3), signif(c1$f[["THETA2"]], 3), NA),
  EC50 = c(signif(c0$f[["THETA3"]], 3), signif(c1$f[["THETA3"]], 3), NA),
  OVDP = c(NA, signif(c1$f[["THETA4"]], 3), signif(c2$f[["THETA2"]], 3)),
  OM_LAM0 = signif(c(c0$f[["OMEGA.1.1."]], c1$f[["OMEGA.1.1."]], c2$f[["OMEGA.1.1."]]), 3))
c(RSE_EMAX = rse(c1, "THETA2"), RSE_EC50 = rse(c1, "THETA3"), RSE_OVDP = rse(c1, "THETA4"))
# The parameters are wrong and the effect is right: the reduction in seizure
# rate over the observed exposure range.
eff <- function(emax, ec50, c) emax * c / (ec50 + c)
cav <- c(0.42, 0.83)
rbind(truth = round(eff(truth[["CNT_EMAX"]], truth[["CNT_EC50"]], cav), 3),
      estimated = round(eff(c1$f[["THETA2"]], c1$f[["THETA3"]], cav), 3))
