# PCA observations for four subjects with the individual predictions of the
# simultaneous model (wf201). The time of the nadir differs from person to person.
s <- read.table(nmf("wf201", "sdtab"), skip = 1, header = TRUE)
s <- s[s$MDV == 0 & s$DVID == 2, ]
ids <- c(2, 7, 18, 31)
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (i in ids) {
  z <- s[s$ID == i, ]
  plot(z$TIME, z$DV, pch = 16, col = "#B2182B", ylim = c(0, 130), xlab = "time (h)",
       ylab = "", main = paste("ID", i))
  lines(z$TIME, z$IPRE, col = "#123669", lwd = 1.5)
  lines(z$TIME, z$PRED, col = "grey60", lty = 2)
}
mtext("PCA (%)", side = 2, outer = TRUE, line = -0.5)
