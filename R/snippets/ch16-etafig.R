# 청소율 ETA 의 분포. 한 덩어리가 아니라 둘이다. 아집단이 있다는 첫 신호이고,
# 이것을 보지 않고 OMEGA 만 읽으면 "CL 의 변이가 크다" 로 끝난다.
pa <- read.table(nmf("121iov", "patab"), skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
pop <- d$POP[!duplicated(d$ID)]
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
hist(pa$ETA2, breaks = 24, col = "#12366955", border = "white", main = "",
     xlab = "ETA(CL)", ylab = "사람 수")
rug(pa$ETA2[pop == 2], col = "#B2182B", lwd = 2)
qqnorm(pa$ETA2, pch = 16, col = "#123669", main = "", xlab = "정규 분위수", ylab = "ETA(CL)")
qqline(pa$ETA2, col = "grey50")
shapiro.test(pa$ETA2)$p.value
