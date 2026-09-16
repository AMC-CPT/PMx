# Gompertz 블록 모형(tg102b)의 추정치. ALPHA 와 BETA 의 개체간 상관을 본다.
e   <- read.table("nm/tg102b.R76/tg102b.ext", skip = 1, header = TRUE)
f   <- unlist(e[e$ITERATION == -1000000000, -1])
s   <- unlist(e[e$ITERATION == -1000000001, -1])
key <- c(ALPHA = "THETA1", BETA = "THETA2", 가법SD = "THETA3", 비례CV = "THETA4",
         OM_A = "OMEGA.1.1.", OM_AB = "OMEGA.2.1.", OM_B = "OMEGA.2.2.")
data.frame(추정 = signif(f[key], 3), RSE = round(100 * s[key] / abs(f[key]), 1),
           row.names = names(key))
c(상관 = round(unname(f["OMEGA.2.1."] / sqrt(f["OMEGA.1.1."] * f["OMEGA.2.2."])), 3),
  최대부피_mm3 = round(unname(exp(f["THETA1"] / f["THETA2"]))))  # V0*exp(alpha/beta), V0=1
