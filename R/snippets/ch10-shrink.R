# shrinkage. EBE 의 표준편차가 추정된 OMEGA 보다 얼마나 작아졌는가.
# 자료가 개체를 말해 주지 못하면 EBE 가 0 쪽으로 끌려간다.
shrink <- function(m, tab) {
  f <- fin(m)
  s <- read.table(nmf(m, tab), skip = 1, header = TRUE)
  s <- s[!duplicated(s$ID), ]
  round(100 * c(ETA1 = 1 - sd(s$ETA1) / sqrt(f[["OMEGA.1.1."]]),
                ETA2 = 1 - sd(s$ETA2) / sqrt(f[["OMEGA.2.2."]])), 1)
}
rbind(기저 = shrink("100base", "patab"), 최종 = shrink("108wt", "patab"))
