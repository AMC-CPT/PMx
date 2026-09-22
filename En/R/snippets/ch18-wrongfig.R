# The population predictions (PRED) of the three mechanisms laid over the mean
# observed PCA. On the population curve alone there are times where all three
# look alike; where they part is near the nadir and in the recovery phase.
pr <- function(m) { s <- read.table(nmf(m, "sdtab"), skip = 1, header = TRUE)
  s <- s[s$MDV == 0 & s$DVID == 2, ]; tapply(s$PRED, s$TIME, mean) }
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(tp, mp, pch = 16, col = "#B2182B", ylim = c(20, 110), xlab = "time (h)",
     ylab = "PCA (%)", main = "population prediction")
cols <- c(wf201 = "#123669", wf203 = "#4DAF4A", wf202 = "grey40")
for (m in names(cols)) { p <- pr(m); lines(as.numeric(names(p)), p, col = cols[m], lwd = 2,
                                            lty = c(wf201 = 1, wf203 = 2, wf202 = 3)[m]) }
legend("bottomright", c("observed mean", "type I", "type IV", "effect compartment"),
       pch = c(16, NA, NA, NA),
       lty = c(NA, 1, 2, 3), col = c("#B2182B", cols), bty = "n", cex = 0.85)
# The time course of CWRES. A wrong mechanism bends its residuals over time.
s2 <- read.table(nmf("wf202", "sdtab"), skip = 1, header = TRUE)
s2 <- s2[s2$MDV == 0 & s2$DVID == 2, ]
plot(s2$TIME, s2$CWRES, pch = 16, cex = 0.5, col = "#12366955", xlab = "time (h)",
     ylab = "CWRES (PCA)", main = "residuals of the effect-compartment model")
lines(lowess(s2$TIME, s2$CWRES, f = 0.4), col = "#B2182B", lwd = 2); abline(h = 0, lty = 3)
