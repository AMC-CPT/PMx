# 잔차 크기에 개체간 변이를 두는 모형(124etaeps). 이 자료에는 그런 것을 넣지
# 않았으므로 분산이 0 근처로 가고 RSE 가 커야 옳다.
e4 <- fin("124etaeps")
c(OFV = round(e4$f[["OBJ"]], 2), dOFV = round(e4$f[["OBJ"]] - b$f[["OBJ"]], 2),
  OM_EPS = signif(e4$f[["OMEGA.4.4."]], 3),
  RSE = round(100 * e4$s[["OMEGA.4.4."]] / e4$f[["OMEGA.4.4."]], 1))
