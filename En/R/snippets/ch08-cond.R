# The condition number is the largest eigenvalue of the correlation matrix
# divided by the smallest. With $COV PRINT=E, NONMEM prints those eigenvalues in
# the .lst. We compute them again.
#
# **The diagonal of the .cor file is not correlation but standard error.** It
# must be set to 1 to make a correlation matrix. A fixed parameter (here
# SIGMA(1,1)) comes out as an all-zero row and column, so it is dropped.
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

signif(sort(eigen(C, symmetric = TRUE)$values), 3)   # must match the .lst
c(condition.number = round(kap(C), 1))
