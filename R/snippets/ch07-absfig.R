# 네 명의 관측과 세 흡수 모형의 개체 예측. 첫 두 시간이 모형을 가른다.
sdt <- function(m) { s <- read.table(nmf(m, "sdtab"), skip = 1, header = TRUE); s[s$MDV == 0, ] }
s1 <- sdt("110ka"); s2 <- sdt("111lag"); s3 <- sdt("112zo")
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (i in c(1, 5, 9, 12)) {
  o <- s1[s1$ID == i, ]
  plot(o$TIME, o$DV, pch = 16, xlim = c(0, 25), ylim = c(0, 12), xlab = "시간 (h)",
       ylab = "", main = paste("ID", i))
  lines(o$TIME, o$IPRE, col = "#123669", lwd = 1.5)
  lines(o$TIME, s2$IPRE[s2$ID == i], col = "#B2182B", lwd = 1.5, lty = 2)
  lines(o$TIME, s3$IPRE[s3$ID == i], col = "#4DAF4A", lwd = 1.5, lty = 3)
}
mtext("농도 (mg/L)", side = 2, outer = TRUE, line = -0.5)
legend("topright", c("1차", "1차+지연", "0차"), col = c("#123669", "#B2182B", "#4DAF4A"),
       lty = 1:3, lwd = 1.5, bty = "n", cex = 0.8)
