# 군별 Kaplan-Meier 곡선. 모형이 재현해야 하는 첫 그림이다.
par(mar = c(4, 4, 1, 1))
plot(km, col = c("#B2182B", "#4DAF4A", "#123669"), lwd = 2, xlab = "개월",
     ylab = "사건 없이 남은 비율", mark.time = TRUE)
legend("bottomleft", c("위약", "50 mg", "100 mg"), col = c("#B2182B", "#4DAF4A", "#123669"),
       lwd = 2, bty = "n")
abline(h = 0.5, lty = 3)
