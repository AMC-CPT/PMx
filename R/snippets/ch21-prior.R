# 신생아 30명만으로 성숙 모형을 세울 수 있는가. 사전 정보 없이(ped103x),
# 나머지 90명(ped104)의 추정치를 NWPRI 사전분포로 넣고(ped103).
px <- fin("ped103x"); pp <- fin("ped103"); po <- fin("ped104")
key <- c(CLSTD = "THETA1", VSTD = "THETA2", TM50 = "THETA5", OM_CL = "OMEGA.1.1.", OM_V = "OMEGA.2.2.")
tv <- truth[c("CLSTD", "VSTD", "TM50", "OM_CL", "OM_V")]
rse <- function(r) round(100 * r$s[key] / abs(r$f[key]), 1)
data.frame(참값 = tv, 사전정보원_90명 = signif(po$f[key], 3), RSE = rse(po),
           신생아만 = signif(px$f[key], 3), RSE = rse(px),
           신생아_사전 = signif(pp$f[key], 3), RSE = rse(pp), row.names = names(key))
# 사전분포가 있는 실행의 OFV 에는 사전분포의 벌점이 들어 있어 다른 실행과 견줄 수 없다.
c(OFV_신생아만 = round(px$f[["OBJ"]], 2), OFV_사전 = round(pp$f[["OBJ"]], 2))
