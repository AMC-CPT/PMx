# 세 설계에서 100번의 추정치. 청소율은 어느 설계에서도 정해지지만, 흡수속도와
# 개체간 변이는 채혈 시각이 정한다. 특이한 설계(sparse2)는 경계로 달아난 값이 많다.
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
for (v in c("CL", "KA", "OM_KA")) {
  boxplot(ok[[v]] ~ factor(ok$DESIGN, levels = c("rich", "sparse3", "sparse2")), col = "#12366933",
          xlab = "", ylab = v, main = v, outline = TRUE, pch = 16, cex = 0.5)
  abline(h = psi0[v], col = "#B2182B", lty = 2)
}
