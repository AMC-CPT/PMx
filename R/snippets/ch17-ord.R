# 같은 NRS 를 세 범주로 접어 비례 오즈 모형(pd200ord)으로 적합했다.
po <- fin("pd200ord")
key4 <- c(A1 = "THETA1", A1_A2 = "THETA2", PLMAX = "THETA3", KPL = "THETA4",
          EMAX = "THETA5", EC50 = "THETA6", OM_A1 = "OMEGA.1.1.")
data.frame(추정 = signif(po$f[key4], 3), RSE = round(100 * po$s[key4] / abs(po$f[key4]), 1),
           row.names = names(key4))
# 예측 확률과 관측 비율. 군마다 시각마다 "중증(7-10)" 의 비율을 견준다.
s  <- read.table(nmf("pd200ord", "sdtab"), skip = 1, header = TRUE)
s  <- s[s$MDV == 0, ]
obs <- tapply(s$DV == 2, list(s$TIME, s$ARM), mean)
pre <- tapply(s$P2, list(s$TIME, s$ARM), mean)            # P2 = P(Y >= 2), 집단 예측
colnames(obs) <- colnames(pre) <- c("위약", "40 mg", "80 mg", "160 mg")
round(cbind(관측 = obs, 예측 = pre)[c("0", "2", "8", "24"), ], 2)
