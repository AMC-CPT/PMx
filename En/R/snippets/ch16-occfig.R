# Three occasions for four people. The same person, yet the curve differs by
# occasion. That difference is IOV. Number 3 is in the subpopulation (30 % of
# the clearance), so the concentrations are higher and fall later.
ids <- c(1, 3, 5, 9)
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (i in ids) {
  o <- obs[obs$ID == i, ]
  plot(NA, xlim = c(0, 24), ylim = c(0, 5.5), xlab = "time after dose (h)", ylab = "",
       main = paste0("ID ", i, if (o$POP[1] == 2) " (reduced)" else ""))
  for (k in 1:3) {
    z <- o[o$OCC == k, ]
    lines(z$TIME - c(0, 168, 336)[k], z$DV, type = "b", pch = c(16, 1, 17)[k],
          col = c("#123669", "#B2182B", "#4DAF4A")[k], cex = 0.8)
  }
  if (i == ids[1]) legend("topright", paste0("occasion ", 1:3), pch = c(16, 1, 17),
                          col = c("#123669", "#B2182B", "#4DAF4A"), bty = "n", cex = 0.85)
}
mtext("concentration (mg/L)", side = 2, outer = TRUE, line = -0.5)
