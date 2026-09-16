# S1 이 첫 쪽에 놓는 숫자들. 손으로 구해 두면 PDF 를 열지 않고도 대조된다.
e <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
f <- unlist(e[e$ITERATION == -1000000000, -1])
d <- read.csv("data/pheno-nm.csv")
nobs <- sum(d$MDV == 0)

c(레코드 = nrow(d), 관측 = nobs,
  모수 = sum(!names(f) %in% c("OBJ", "SIGMA.1.1.")),   # SIGMA 는 고정이다
  OFV = round(f[["OBJ"]], 3),
  OFV당관측 = round(f[["OBJ"]] / nobs, 4))
