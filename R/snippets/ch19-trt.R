# 치료군을 넣은 모의 자료(참값 -0.40)를 두 모형으로 적합했다.
# tg106: 치료효과 없음.  tg107: 치료가 7일부터 ALPHA 를 (1 + THETA(5)) 배로.
fin <- function(m) {
  e <- read.table(file.path("nm", paste0(m, ".R76"), paste0(m, ".ext")),
                  skip = 1, header = TRUE)
  list(f = unlist(e[e$ITERATION == -1000000000, -1]),
       s = unlist(e[e$ITERATION == -1000000001, -1]))
}
r0 <- fin("tg106"); r1 <- fin("tg107")
c(OFV_없음 = round(r0$f[["OBJ"]], 2), OFV_효과 = round(r1$f[["OBJ"]], 2),
  dOFV = round(r0$f[["OBJ"]] - r1$f[["OBJ"]], 2))
c(효과추정 = round(r1$f[["THETA5"]], 3), RSE = round(100 * r1$s[["THETA5"]] / abs(r1$f[["THETA5"]]), 1),
  참값 = -0.40,
  하한 = round(r1$f[["THETA5"]] - 1.96 * r1$s[["THETA5"]], 3),
  상한 = round(r1$f[["THETA5"]] + 1.96 * r1$s[["THETA5"]], 3))

# TGI 지표. 21일의 전형 부피 비 T/C. 치료의 크기를 성장률이 아니라 부피로 말한다.
a <- r1$f[["THETA1"]]; b <- r1$f[["THETA2"]]; ef <- r1$f[["THETA5"]]
V  <- function(t, aa) exp(aa / b * (1 - exp(-b * t)))
v7 <- V(7, a)
vt <- v7 * exp(a * (1 + ef) / b * (exp(-b * 7) - exp(-b * 21)))
c(대조_21일 = round(V(21, a)), 치료_21일 = round(vt), TC비 = round(vt / V(21, a), 2))
