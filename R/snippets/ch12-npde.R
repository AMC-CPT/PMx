# NPDE. npde 패키지가 앞 상자의 네 단계를 그대로 밟는다(탈상관은 Cholesky 분해).
# 관측과 모의는 같은 행 순서여야 하고, 모의는 재현마다 관측 전체를 쌓은 긴 형식이다.
library(npde)
x <- autonpde(namobs = obs[, c("ID", "TIME", "DV")], namsim = sim[, c("ID", "TIME", "DV")],
              iid = 1, ix = 2, iy = 3, boolsave = FALSE, verbose = FALSE)
res <- x@results@res                       # ypred, pd, npde 등
head(round(res[, c("ypred", "pd", "npde")], 3), 3)
# 탈상관 전(npd = qnorm(pd))과 후(npde)의 정규성. 같은 자료, 같은 모의다.
round(c(SW.npd = shapiro.test(qnorm(res$pd))$p.value,
        SW.npde = shapiro.test(res$npde)$p.value), 3)

par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
qqnorm(res$npde, pch = 16, col = "#12366999", main = "정규 QQ",
       xlab = "정규분위수", ylab = "NPDE")
abline(0, 1)
plot(obs$TIME, res$npde, pch = 16, col = "#12366999", xlab = "시간 (h)",
     ylab = "NPDE", main = "시간에 따라")
abline(h = c(-1.96, 0, 1.96), lty = c(2, 1, 2))
