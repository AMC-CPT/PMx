# The mean time course of concentration and of PCA, and the two put against each
# other as a hysteresis loop. While the concentration is already falling, the
# PCA is still falling. Time runs in the direction of the arrows.
cp <- obs[obs$DVID == 1, ]
mc <- tapply(cp$DV, cp$TIME, mean); tc <- as.numeric(names(mc))
mp <- tapply(pca$DV, pca$TIME, mean); tp <- as.numeric(names(mp))
par(mfrow = c(1, 3), mar = c(4, 4, 1.5, 1))
plot(tc, mc, type = "b", pch = 16, col = "#123669", xlab = "time (h)",
     ylab = "concentration (mg/L)", main = "concentration")
plot(tp, mp, type = "b", pch = 16, col = "#B2182B", xlab = "time (h)", ylab = "PCA (%)",
     ylim = c(0, 110), main = "PCA")
# Join concentration and PCA at the same time. Interpolate the concentration to
# the PCA times.
ci <- approx(tc, mc, xout = tp[tp > 0], rule = 2)$y
plot(ci, mp[tp > 0], type = "b", pch = 16, col = "grey30", xlab = "concentration (mg/L)",
     ylab = "PCA (%)", main = "hysteresis loop")
arrows(ci[-length(ci)], mp[tp > 0][-length(ci)], ci[-1], mp[tp > 0][-1],
       length = 0.08, col = "#B2182B")
text(ci, mp[tp > 0], labels = paste0(tp[tp > 0], "h"), pos = 4, cex = 0.7)
