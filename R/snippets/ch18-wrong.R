# 같은 자료에 세 기전. I 형(합성 억제, wf201), IV 형(소실 자극, wf203),
# 효과구획 + 직접 Emax(wf202). 모수 수가 다르므로 AIC 로 견준다.
mods <- c(wf201 = "간접반응 I 형 (kin 억제)", wf203 = "간접반응 IV 형 (kout 자극)",
          wf202 = "효과구획 + 직접 Emax")
tab <- t(sapply(names(mods), function(m) {
  r <- fin(m); f <- r$f
  p <- sum(grepl("THETA|OMEGA", names(f)) & f != 0)
  c(OFV = round(f[["OBJ"]], 1), 모수 = p, AIC = round(f[["OBJ"]] + 2 * p, 1),
    PD가법SD = signif(f[["THETA8"]], 3))
}))
data.frame(기전 = mods, tab, row.names = NULL)
# wf202 의 소실 기전이 정말 없는 것인가: 종료 메시지를 본다.
grep("MINIMIZATION|PROBLEMS", readLines(nmf("wf202", "wf202.lst")), value = TRUE)
