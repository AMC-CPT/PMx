# 완전 모형: 108wt 에 CREA, APGR, SEX 를 한꺼번에 넣은 108full.
# 검색하지 않고 효과의 크기와 95 % 구간을 읽는다.
f <- fin("108full"); fs <- se("108full")
ci <- function(k) c(추정 = f[[k]], 하한 = f[[k]] - 1.96 * fs[[k]], 상한 = f[[k]] + 1.96 * fs[[k]])
rbind(`CREA~CL` = ci("THETA7"), `APGR~CL` = ci("THETA8"), `SEX~CL` = ci("THETA9"))
dOFV <- fin("108wt")[["OBJ"]] - f[["OBJ"]]
c(dOFV = dOFV, df = 3, p = pchisq(dOFV, df = 3, lower.tail = FALSE))

# 값을 치른 곳: 청소율 개체간 변이의 RSE
w <- fin("108wt"); ws <- se("108wt")
c(`RSE % om(CL) 108wt` = 100 * ws[["OMEGA.1.1."]] / w[["OMEGA.1.1."]],
  `108full` = 100 * fs[["OMEGA.1.1."]] / f[["OMEGA.1.1."]])
