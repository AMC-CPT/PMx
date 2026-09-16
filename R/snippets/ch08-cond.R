# 조건수는 상관행렬의 최대 고유값 / 최소 고유값이다.
# NONMEM 은 $COV PRINT=E 면 그 고유값을 .lst 에 찍는다. 우리가 다시 구해 본다.
#
# .cor 파일의 **대각은 상관이 아니라 표준오차**다. 1 로 바꿔야 상관행렬이 된다.
# 고정된 모수(여기서는 SIGMA(1,1))는 행과 열이 전부 0 으로 나오므로 뺀다.
read_cor <- function(m) {
  x <- read.table(nmf(m, paste0(m, ".cor")), skip = 1, header = TRUE,
                  row.names = 1, check.names = FALSE)
  C <- as.matrix(x); k <- diag(C) != 0
  C <- C[k, k, drop = FALSE]; diag(C) <- 1
  C
}
kap <- function(C) { e <- eigen(C, symmetric = TRUE)$values; max(e) / min(e) }

C <- read_cor("100base")
rownames(C)

signif(sort(eigen(C, symmetric = TRUE)$values), 3)   # .lst 의 값과 같아야 한다
c(조건수 = round(kap(C), 1))
