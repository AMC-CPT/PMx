# 회차별 청소율. sdtab 의 CL 은 회차 효과가 더해진 값이다. 사람마다 세 점을
# 그 사람의 기하평균으로 나누면 회차 효과만 남는다. 폭이 IOV 의 크기다.
s <- read.table(nmf("121iov", "sdtab"), skip = 1, header = TRUE)
s <- s[!duplicated(paste(s$ID, s$OCC)), c("ID", "OCC", "CL", "KA", "IOVC", "IOVK")]
gm <- tapply(log(s$CL), s$ID, mean)
s$RCL <- exp(log(s$CL) - gm[as.character(s$ID)])
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(jitter(s$OCC, 0.3), s$RCL, pch = 16, cex = 0.6, col = "#12366966", xaxt = "n",
     xlab = "회차", ylab = "CL / 개인 기하평균", ylim = c(0.5, 1.7))
axis(1, 1:3); abline(h = 1, lty = 2)
abline(h = exp(c(-1, 1) * 1.96 * sqrt(truth[["PI_CL"]])), col = "#B2182B", lty = 3)
hist(s$IOVC, breaks = 20, col = "#12366955", border = "white", main = "",
     xlab = "회차 효과 (CL, 로그 척도)")
c(SD_추정 = round(sd(s$IOVC), 3), SD_참값 = round(sqrt(truth[["PI_CL"]]), 3))
