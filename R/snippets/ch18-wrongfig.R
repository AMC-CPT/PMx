# 세 기전의 집단 예측(PRED)을 PCA 관측 평균 위에 겹친다. 집단 곡선만으로는
# 셋이 비슷하게 보이는 시각이 있고, 갈리는 곳은 최저점 근처와 회복기다.
pr <- function(m) { s <- read.table(nmf(m, "sdtab"), skip = 1, header = TRUE)
  s <- s[s$MDV == 0 & s$DVID == 2, ]; tapply(s$PRED, s$TIME, mean) }
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(tp, mp, pch = 16, col = "#B2182B", ylim = c(20, 110), xlab = "시간 (h)",
     ylab = "PCA (%)", main = "집단 예측")
cols <- c(wf201 = "#123669", wf203 = "#4DAF4A", wf202 = "grey40")
for (m in names(cols)) { p <- pr(m); lines(as.numeric(names(p)), p, col = cols[m], lwd = 2,
                                            lty = c(wf201 = 1, wf203 = 2, wf202 = 3)[m]) }
legend("bottomright", c("관측 평균", "I 형", "IV 형", "효과구획"), pch = c(16, NA, NA, NA),
       lty = c(NA, 1, 2, 3), col = c("#B2182B", cols), bty = "n", cex = 0.85)
# CWRES 의 시간 경과. 틀린 기전은 잔차가 시간에 따라 굽는다.
s2 <- read.table(nmf("wf202", "sdtab"), skip = 1, header = TRUE)
s2 <- s2[s2$MDV == 0 & s2$DVID == 2, ]
plot(s2$TIME, s2$CWRES, pch = 16, cex = 0.5, col = "#12366955", xlab = "시간 (h)",
     ylab = "CWRES (PCA)", main = "효과구획 모형의 잔차")
lines(lowess(s2$TIME, s2$CWRES, f = 0.4), col = "#B2182B", lwd = 2); abline(h = 0, lty = 3)
