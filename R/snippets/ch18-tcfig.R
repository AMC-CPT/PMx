# 농도와 PCA 의 평균 시간 경과, 그리고 둘을 맞붙인 이력 고리(hysteresis loop).
# 농도가 이미 내려가는 동안 PCA 는 아직 내려가고 있다. 시간이 화살표 방향이다.
cp <- obs[obs$DVID == 1, ]
mc <- tapply(cp$DV, cp$TIME, mean); tc <- as.numeric(names(mc))
mp <- tapply(pca$DV, pca$TIME, mean); tp <- as.numeric(names(mp))
par(mfrow = c(1, 3), mar = c(4, 4, 1.5, 1))
plot(tc, mc, type = "b", pch = 16, col = "#123669", xlab = "시간 (h)", ylab = "농도 (mg/L)",
     main = "농도")
plot(tp, mp, type = "b", pch = 16, col = "#B2182B", xlab = "시간 (h)", ylab = "PCA (%)",
     ylim = c(0, 110), main = "PCA")
# 같은 시각의 농도와 PCA 를 잇는다. 농도는 PCA 시각에 보간한다.
ci <- approx(tc, mc, xout = tp[tp > 0], rule = 2)$y
plot(ci, mp[tp > 0], type = "b", pch = 16, col = "grey30", xlab = "농도 (mg/L)",
     ylab = "PCA (%)", main = "이력 고리")
arrows(ci[-length(ci)], mp[tp > 0][-length(ci)], ci[-1], mp[tp > 0][-1],
       length = 0.08, col = "#B2182B")
text(ci, mp[tp > 0], labels = paste0(tp[tp > 0], "h"), pos = 4, cex = 0.7)
