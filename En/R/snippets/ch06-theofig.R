# The same table as a picture. Eleven points line up on the 320 mg line and
# only subject 9 sits away from it.
par(mar = c(4, 4, 1, 1))
plot(dz$ID, dz$TOTAL, pch = 16, col = "#123669", xaxt = "n", ylim = c(260, 330),
     xlab = "subject", ylab = "dose x body weight (mg)")
axis(1, at = dz$ID)
abline(h = 320, lty = 2)
text(9, 267.8, "3.10 x 86.4", pos = 4, cex = 0.85)
