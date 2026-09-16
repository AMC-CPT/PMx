# 전진선택. 기저 모형에서 한 걸음씩 넣고 OFV 가 얼마나 떨어지는지 본다.
# 중첩 모형이므로 자유도 1 의 카이제곱을 쓴다. 전진 문턱은 3.84 (p<0.05).
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
ofv <- function(m) fin(m)[["OBJ"]]

step1 <- c(기저 = ofv("100base"), CL에체중 = ofv("106wtcl"), V에체중 = ofv("107wtv"))
round(rbind(OFV = step1, dOFV = step1 - step1[["기저"]]), 2)

# V 에 체중을 넣은 것이 더 크게 떨어뜨렸다. 거기서 한 걸음 더 간다.
step2 <- c(V에체중 = ofv("107wtv"), 둘다 = ofv("108wt"))
round(c(dOFV = diff(step2), 문턱 = 3.84), 2)
