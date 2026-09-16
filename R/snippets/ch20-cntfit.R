# Poisson(cnt100), 음이항(cnt101), 약효 없는 음이항(cnt102).
c0 <- fin("cnt100"); c1 <- fin("cnt101"); c2 <- fin("cnt102")
data.frame(
  모형 = c("Poisson + 약효", "음이항 + 약효", "음이항, 약효 없음"),
  OFV = round(c(c0$f[["OBJ"]], c1$f[["OBJ"]], c2$f[["OBJ"]]), 1),
  LAM0 = signif(c(c0$f[["THETA1"]], c1$f[["THETA1"]], c2$f[["THETA1"]]), 3),
  EMAX = c(signif(c0$f[["THETA2"]], 3), signif(c1$f[["THETA2"]], 3), NA),
  EC50 = c(signif(c0$f[["THETA3"]], 3), signif(c1$f[["THETA3"]], 3), NA),
  OVDP = c(NA, signif(c1$f[["THETA4"]], 3), signif(c2$f[["THETA2"]], 3)),
  OM_LAM0 = signif(c(c0$f[["OMEGA.1.1."]], c1$f[["OMEGA.1.1."]], c2$f[["OMEGA.1.1."]]), 3))
c(RSE_EMAX = rse(c1, "THETA2"), RSE_EC50 = rse(c1, "THETA3"), RSE_OVDP = rse(c1, "THETA4"))
# 모수는 틀렸는데 효과는 맞는다: 관측된 노출 범위에서의 발작률 감소.
eff <- function(emax, ec50, c) emax * c / (ec50 + c)
cav <- c(0.42, 0.83)
rbind(참값 = round(eff(truth[["CNT_EMAX"]], truth[["CNT_EC50"]], cav), 3),
      추정 = round(eff(c1$f[["THETA2"]], c1$f[["THETA3"]], cav), 3))
