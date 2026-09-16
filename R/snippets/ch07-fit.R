# 추정 결과는 .ext 에 있다. ITERATION 이 -1000000000 인 줄이 최종 추정치다.
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
b <- fin("100base")

data.frame(추정치 = round(b[paste0("THETA", 1:4)], 4),
           row.names = c("CL (L/h)", "V (L)", "가법오차 SD (mg/L)", "비례오차 CV"))
c(OFV = round(b[["OBJ"]], 2))
