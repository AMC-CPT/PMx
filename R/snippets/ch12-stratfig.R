# 층화 VPC. 체중 중앙값으로 두 층을 나누고, 같은 구간과 같은 분위수를 층마다 구한다.
co <- read.table(nmf("108wt", "cotab"), skip = 1, header = TRUE)
co <- co[!duplicated(co$ID), ]
cutwt <- median(co$WT)
grp <- setNames(ifelse(co$WT > cutwt, "무거운 반", "가벼운 반"), co$ID)
obs$GRP <- grp[as.character(obs$ID)]
sim$GRP <- grp[as.character(sim$ID)]
rbind(대상자 = table(grp), 관측 = table(obs$GRP))

band <- function(o, s) {                            # 층 하나의 관측·모의 분위수
  oq <- sapply(qs, function(q) tapply(o$DV, o$BIN, quantile, q))
  sq <- sapply(qs, function(q) {
    m <- tapply(seq_len(nrow(s)), list(s$BIN, s$REP),
                function(i) quantile(s$DV[i], q))
    t(apply(m, 1, quantile, c(0.025, 0.5, 0.975), na.rm = TRUE))
  }, simplify = "array")
  list(x = as.numeric(mid(o$TIME)), oq = oq, sq = sq)
}
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
for (g in c("가벼운 반", "무거운 반")) {
  o <- obs[obs$GRP == g, ]; s <- sim[sim$GRP == g, ]; b <- band(o, s)
  k <- !is.na(b$x)
  plot(o$TIME, o$DV, pch = 16, col = "#12366933", xlab = "시간 (h)",
       ylab = "농도 (mg/L)", ylim = c(0, max(obs$DV) * 1.05),
       main = paste0(g, " (", ifelse(g == "가벼운 반", "<=", ">"), " ", cutwt, " kg)"))
  for (j in 1:3) {
    polygon(c(b$x[k], rev(b$x[k])), c(b$sq[k, 1, j], rev(b$sq[k, 3, j])),
            col = "#12366922", border = NA)
    lines(b$x[k], b$oq[k, j], lwd = 2, lty = if (j == 2) 1 else 2)
  }
}
