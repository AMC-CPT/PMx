# 귀무분포의 범위에 맞춰 그린다. 실제 값은 축 밖이므로 화살표로 가리킨다.
# (한 그림에 같이 넣으면 귀무분포가 왼쪽 끝에 눌려 보이지 않는다.)
xmax <- max(null, qchisq(0.95, 2)) * 1.35
par(mar = c(4, 4, 1.5, 1))
h <- hist(null, breaks = 20, col = "#12366955", border = "white",
          xlim = c(0, xmax), xlab = "dOFV", ylab = "빈도", main = "")
ymax <- max(h$counts)

abline(v = qchisq(0.95, 2), lty = 2)                     # 카이제곱 95 백분위수
text(qchisq(0.95, 2), ymax, "카이제곱 95%", pos = 4, cex = 0.9)
arrows(xmax * 0.80, ymax * 0.45, xmax * 0.99, ymax * 0.45, length = 0.12, lwd = 2)
text(xmax * 0.80, ymax * 0.58, sprintf("실제 %.1f", obs), pos = 4, font = 2)
