# NONMEM 이 적분한 민감도를 꺼내 R 의 적분과 맞춘다. 110des 는 theophylline 을
# ADVAN13 으로 쓰고 verbatim 코드로 DAETA(2,j) = dA2/dETA(j) 와 G(j,1) 을 표에 냈다.
# 같은 것을 R 에서 상태 2개 + 민감도 6개, 여덟 개의 미분방정식으로 푼다.
library(deSolve)
s  <- read.table("nm/110des.R76/sdtab", skip = 1, header = TRUE)
pa <- read.table("nm/110des.R76/patab", skip = 1, header = TRUE)
i  <- 1
p  <- pa[pa$ID == i, ][1, ]                        # 이 사람의 개인 모수 (EBE 반영)
ka <- p$KA; cl <- p$CL; v <- p$V; ke <- cl / v
# 상태 y1, y2 와 B[j,i] = dA_j/dETA_i.  ETA1->KA, ETA2->CL, ETA3->V.
# dKA/dETA1 = KA, dKE/dETA2 = KE, dKE/dETA3 = -KE (KE = CL/V 이므로).
f <- function(t, y, parms) {
  A1 <- y[1]; A2 <- y[2]
  list(c(-ka * A1,  ka * A1 - ke * A2,
         -ka * A1 - ka * y[3],                 ka * A1 + ka * y[3] - ke * y[4],   # ETA1
         -ka * y[5],                           ka * y[5] - ke * A2 - ke * y[6],   # ETA2
         -ka * y[7],                           ka * y[7] + ke * A2 - ke * y[8]))  # ETA3
}
obs <- s[s$ID == i & s$MDV == 0, ]
amt <- s$AMT[s$ID == i & s$EVID == 1][1]
out <- ode(y = c(amt, 0, 0, 0, 0, 0, 0, 0), times = c(0, obs$TIME), func = f, parms = NULL,
           rtol = 1e-9, atol = 1e-12)[-1, ]
r <- data.frame(TIME = obs$TIME, A2_R = out[, 3], DA21_NM = obs$DA21, DA21_R = out[, 5],
                DA23_NM = obs$DA23, DA23_R = out[, 9])
print(round(r, 4), row.names = FALSE)
# 8장의 식: dF/dETA = (dA/dETA - F * dV/dETA) / V.  V 는 ETA3 에만 걸린다.
F  <- out[, 3] / v
G3 <- (out[, 9] - F * v) / v
c(최대차_G1 = max(abs(obs$G1 - out[, 5] / v)), 최대차_G3 = max(abs(obs$G3 - G3)))
