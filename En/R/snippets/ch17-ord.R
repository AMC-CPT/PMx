# The same NRS folded into three categories and fitted with a proportional odds
# model (pd200ord).
po <- fin("pd200ord")
key4 <- c(A1 = "THETA1", A1_A2 = "THETA2", PLMAX = "THETA3", KPL = "THETA4",
          EMAX = "THETA5", EC50 = "THETA6", OM_A1 = "OMEGA.1.1.")
data.frame(estimate = signif(po$f[key4], 3), RSE = round(100 * po$s[key4] / abs(po$f[key4]), 1),
           row.names = names(key4))
# Predicted probability against observed proportion. Per arm and per time, the
# proportion of "severe (7-10)".
s  <- read.table(nmf("pd200ord", "sdtab"), skip = 1, header = TRUE)
s  <- s[s$MDV == 0, ]
obs <- tapply(s$DV == 2, list(s$TIME, s$ARM), mean)
pre <- tapply(s$P2, list(s$TIME, s$ARM), mean)            # P2 = P(Y >= 2), population prediction
colnames(obs) <- colnames(pre) <- c("placebo", "40 mg", "80 mg", "160 mg")
round(cbind(observed = obs, predicted = pre)[c("0", "2", "8", "24"), ], 2)
