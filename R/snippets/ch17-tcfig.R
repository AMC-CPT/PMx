# 군별 NRS 의 시간 경과. 위약군도 내려간다. 그것이 자연 회복이고, 약효는
# 위약군과의 차이다. 위약군이 없으면 그 차이를 알 수 없다.
n <- d[d$DVID == 2, ]
m <- tapply(n$DV, list(n$TIME, n$ARM), mean)
par(mar = c(4, 4, 1, 1))
matplot(as.numeric(rownames(m)), m, type = "b", pch = 16, lty = 1, lwd = 1.5,
        col = c("grey40", "#8DA0CB", "#4F6DB0", "#123669"),
        xlab = "시간 (h)", ylab = "NRS 평균", ylim = c(0, 8))
legend("bottomleft", arm, col = c("grey40", "#8DA0CB", "#4F6DB0", "#123669"),
       pch = 16, lty = 1, bty = "n")
