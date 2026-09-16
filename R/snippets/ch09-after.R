# 넣고 나서 다시 그린다. 기울기가 사라져야 제대로 넣은 것이다.
pa8 <- read.table(nmf("108wt", "patab"), skip = 1, header = TRUE)
s8  <- merge(pa8[!duplicated(pa8$ID), ], co[!duplicated(co$ID), ], by = "ID")
round(cor(s8[, c("ETA1", "ETA2")], s8[, c("WT", "CREA", "APGR")]), 3)

par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
for (e in c("ETA1", "ETA2")) {
  plot(s8$WT, s8[[e]], pch = 16, col = "#12366999", xlab = "체중 (kg)", ylab = e,
       main = paste(e, "(체중 보정 후)"))
  abline(h = 0, lty = 3)
  abline(lm(s8[[e]] ~ s8$WT), lwd = 1.5)
}
