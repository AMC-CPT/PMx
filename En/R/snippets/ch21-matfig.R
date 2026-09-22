# The shape of the maturation function. True TM50 55 weeks, Hill 3.4. The
# neonates (PMA 28-44 weeks) sit on the steep front of the curve, and by age 2
# (PMA about 144 weeks) it has nearly finished rising.
mat <- function(pma, tm50 = 55, hill = 3.4) pma^hill / (tm50^hill + pma^hill)
pma <- seq(24, 200, length.out = 300)
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(pma, mat(pma), type = "l", lwd = 2, col = "#123669", xlab = "PMA (weeks)",
     ylab = "fraction mature", main = "MAT(PMA)")
abline(v = 40, lty = 3); abline(h = 0.5, lty = 3)
rug(s$PMA[s$PMA < 200], col = "#B2182B")
# Clearance with size taken out: CL / (WT/70)^0.75 against PMA. The true
# maturation curve appears.
pa <- read.table("nm/ped101.R76/patab", skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
cls <- pa$CL / (s$WT / 70)^0.75
plot(s$PMA, cls, log = "x", pch = 16, col = c("#B2182B", "#4DAF4A", "#123669", "grey40")[s$GRP],
     xlab = "PMA (weeks, log axis)", ylab = "CL / (WT/70)^0.75 (L/h)",
     main = "clearance with size removed")
lines(pma <- seq(24, 1000, length.out = 300), 6 * mat(pma), lwd = 2)
legend("bottomright", grp, pch = 16, col = c("#B2182B", "#4DAF4A", "#123669", "grey40"),
       bty = "n", cex = 0.8)
