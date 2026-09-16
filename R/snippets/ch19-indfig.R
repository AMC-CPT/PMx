# 네 마리의 관측과 세 모형의 개체 예측. 자료 범위 안에서는 셋이 비슷하고,
# 자료 밖(점선 오른쪽)에서 갈라진다. 외삽이 모형을 가른다.
sd_of <- function(m) { x <- read.table(file.path("nm", paste0(m, ".R76"), "sdtab"),
                                        skip = 1, header = TRUE); x[x$MDV == 0, ] }
s1 <- sd_of("tg101"); s2 <- sd_of("tg102b"); s3 <- sd_of("tg103")
ids <- c(2, 5, 9, 16)
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (i in ids) {
  o <- s2[s2$ID == i, ]
  plot(o$TIME, o$DV, pch = 16, xlim = c(0, 25), ylim = c(0, 2500), xlab = "일",
       ylab = "", main = paste("ID", i))
  lines(o$TIME, s1$IPRE[s1$ID == i], col = "#8DA0CB", lwd = 1.5)
  lines(o$TIME, o$IPRE, col = "#123669", lwd = 1.5)
  lines(o$TIME, s3$IPRE[s3$ID == i], col = "#B2182B", lwd = 1.5, lty = 3)
}
mtext(expression(부피~(mm^3)), side = 2, outer = TRUE, line = -0.5)
legend("topleft", c("로지스틱", "Gompertz", "멱함수"), col = c("#8DA0CB", "#123669", "#B2182B"),
       lty = c(1, 1, 3), lwd = 1.5, bty = "n", cex = 0.8)
