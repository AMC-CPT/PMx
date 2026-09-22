# Left: the individual objective function values. If one person's is unusually
# large, look at that person's data. Right: number of observations against
# individual shrinkage. The fewer observations, the less the EBE is determined.
nobs <- table(read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)$ID[
          read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)$MDV == 0])
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(phi$ID, phi$OBJ, type = "h", lwd = 3, col = "#123669", xlab = "ID",
     ylab = "individual OFV", main = "individual objective function")
abline(h = mean(phi$OBJ) + 2 * sd(phi$OBJ), lty = 3, col = "#B2182B")
plot(jitter(as.numeric(nobs[as.character(phi$ID)]), 0.3), ind$CL, pch = 16, col = "#12366999",
     xlab = "number of observations", ylab = "individual shrinkage of CL", ylim = c(0, 1),
     main = "shrinkage and observations")
