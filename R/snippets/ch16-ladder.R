# 이 장의 사다리. 같은 자료에 다섯 모형. 모수 수와 OFV, 그리고 CL 의 IIV 가
# 어디서 참값으로 돌아오는지를 한 표에 놓는다.
lad <- c(`120base` = "IIV 만", `124etaeps` = "+ 잔차의 IIV", `121iov` = "+ IOV",
         `122mix` = "+ 혼합", `123mixiov` = "+ IOV + 혼합")
tab <- t(sapply(names(lad), function(m) {
  f <- fin(m)$f
  p <- sum(grepl("THETA", names(f)) & f != 0) +
       length(unique(f[grepl("OMEGA", names(f)) & f != 0]))   # SAME 블록은 하나로 센다
  c(모수 = p, OFV = round(f[["OBJ"]], 1), OM_CL = signif(f[["OMEGA.2.2."]], 3))
}))
data.frame(모형 = lad, tab, row.names = NULL)
