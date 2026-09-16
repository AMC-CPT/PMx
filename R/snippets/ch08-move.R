# 적합을 하나도 바꾸지 않는 네 가지 조치가 조건수를 얼마나 흔드는가.
#   102sig   잔차오차 모수를 THETA 에서 SIGMA 로 옮긴다 (분포는 같다)
#   103mats  공분산 추정량을 S 로
#   104matr  공분산 추정량을 R 로
#   105start 초기값만 바꾼다
ofv <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  e[e$ITERATION == -1000000000, "OBJ"]
}
runs <- c("100base", "102sig", "103mats", "104matr", "105start")
tab <- t(sapply(runs, function(m) c(OFV = ofv(m), blocks(read_cor(m)))))
round(tab, 2)
