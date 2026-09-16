# VPC. 모의한 농도의 분포 안에 관측이 들어 있는지를 본다.
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
sim <- read.csv(nmf("108wtsim", "simtab.csv"))          # 200회 x 155 관측
obs <- read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)
obs <- obs[obs$MDV == 0, ]
c(재현 = length(unique(sim$REP)), 관측 = nrow(obs))

# 시간 구간은 관측 수가 고르게 나뉘도록 분위수로 자른다.
brk <- unique(quantile(obs$TIME, seq(0, 1, length.out = 7)))
mid <- function(t) tapply(t, cut(t, brk, include.lowest = TRUE), median)
obs$BIN <- cut(obs$TIME, brk, include.lowest = TRUE)
sim$BIN <- cut(sim$TIME, brk, include.lowest = TRUE)

# 관측의 분위수, 그리고 재현마다 구한 분위수의 분위수(신뢰구간)
qs <- c(0.05, 0.5, 0.95)
oq <- sapply(qs, function(q) tapply(obs$DV, obs$BIN, quantile, q))
sq <- sapply(qs, function(q) {
  m <- tapply(seq_len(nrow(sim)), list(sim$BIN, sim$REP),
              function(i) quantile(sim$DV[i], q))
  t(apply(m, 1, quantile, c(0.025, 0.5, 0.975), na.rm = TRUE))
}, simplify = "array")
round(oq, 1)
