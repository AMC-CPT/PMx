# The fit plot of tm103. One panel per dose group, with the observations (points)
# and individual predictions (solid) per animal and the population prediction
# dashed. Log axis. Look at whether the last observations at the low doses bend
# down below the prediction, and whether the early part fits at the high doses.
# This is the 'typical figure' of a report.
sd <- read.table("nm/tm103.R76/sdtab", skip = 1, header = TRUE)
sd <- sd[sd$MDV == 0, ]
lv <- sort(unique(sd$LVL))
par(mfrow = c(2, 3), mar = c(3.5, 3.5, 1.5, 0.5), mgp = c(2.2, 0.7, 0))
for (L in lv) {
  z <- sd[sd$LVL == L, ]
  plot(NA, xlim = c(0, 150), ylim = c(0.02, 800), log = "y", xlab = "time (h)",
       ylab = "concentration (mg/L)", main = paste(L, "mg/kg"))
  for (i in unique(z$ID)) { o <- z[z$ID == i, ]
    points(o$TIME, o$DV, pch = 16, cex = 0.5, col = "grey40")
    lines(o$TIME, o$IPRE, col = "steelblue", lwd = 0.8) }
  m <- tapply(z$PRED, z$TIME, function(x) exp(mean(log(x))))
  lines(as.numeric(names(m)), m, lty = 2, lwd = 1.5)
}
