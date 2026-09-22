# Draw it again after putting the covariate in. The slope has to be gone for
# it to have gone in properly.
pa8 <- read.table(nmf("108wt", "patab"), skip = 1, header = TRUE)
s8  <- merge(pa8[!duplicated(pa8$ID), ], co[!duplicated(co$ID), ], by = "ID")
round(cor(s8[, c("ETA1", "ETA2")], s8[, c("WT", "CREA", "APGR")]), 3)

par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
for (e in c("ETA1", "ETA2")) {
  plot(s8$WT, s8[[e]], pch = 16, col = "#12366999", xlab = "weight (kg)", ylab = e,
       main = paste(e, "(after weight)"))
  abline(h = 0, lty = 3)
  abline(lm(s8[[e]] ~ s8$WT), lwd = 1.5)
}
