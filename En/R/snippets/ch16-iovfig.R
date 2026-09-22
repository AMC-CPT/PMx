# Clearance by occasion. The CL in the sdtab already carries the occasion
# effect. Divide each person's three points by that person's geometric mean and
# only the occasion effect is left. Its spread is the size of the IOV.
s <- read.table(nmf("121iov", "sdtab"), skip = 1, header = TRUE)
s <- s[!duplicated(paste(s$ID, s$OCC)), c("ID", "OCC", "CL", "KA", "IOVC", "IOVK")]
gm <- tapply(log(s$CL), s$ID, mean)
s$RCL <- exp(log(s$CL) - gm[as.character(s$ID)])
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(jitter(s$OCC, 0.3), s$RCL, pch = 16, cex = 0.6, col = "#12366966", xaxt = "n",
     xlab = "occasion", ylab = "CL / individual geometric mean", ylim = c(0.5, 1.7))
axis(1, 1:3); abline(h = 1, lty = 2)
abline(h = exp(c(-1, 1) * 1.96 * sqrt(truth[["PI_CL"]])), col = "#B2182B", lty = 3)
hist(s$IOVC, breaks = 20, col = "#12366955", border = "white", main = "",
     xlab = "occasion effect (CL, log scale)")
c(SD.estimated = round(sd(s$IOVC), 3), SD.true = round(sqrt(truth[["PI_CL"]]), 3))
