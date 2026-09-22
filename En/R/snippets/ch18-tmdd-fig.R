# Left: the concentrations of all 50 animals (log axis), colored by dose level.
# Right: the geometric mean per dose group divided by the dose. Under linear
# pharmacokinetics the curves on the right would superimpose. The lower the dose
# the earlier the curve bends down and disappears, because the share the target
# captures and removes is larger at low doses; that is the signature of TMDD. At
# high doses the target saturates and it looks like linear pharmacokinetics.
lv <- sort(unique(obs$LVL)); cols <- hcl.colors(9, "Blues 3", rev = TRUE)[4:9]
gm <- function(x) exp(mean(log(x)))
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(NA, xlim = c(0, 150), ylim = c(0.02, 800), log = "y", xlab = "time (h)",
     ylab = "concentration (mg/L)", main = "per animal")
for (i in unique(obs$ID)) { o <- obs[obs$ID == i, ]
  lines(o$TIME, o$DV, col = cols[match(o$LVL[1], lv)], lwd = 0.8) }
plot(NA, xlim = c(0, 150), ylim = c(0.005, 60), log = "y", xlab = "time (h)",
     ylab = "concentration / dose", main = "geometric mean divided by dose")
for (i in seq_along(lv)) { o <- obs[obs$LVL == lv[i], ]; m <- tapply(o$DV / o$LVL, o$TIME, gm)
  lines(as.numeric(names(m)), m, type = "b", pch = 16, cex = 0.7, col = cols[i]) }
legend("bottomleft", paste(lv, "mg/kg"), col = cols, lwd = 2, bty = "n", cex = 0.7)
