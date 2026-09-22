# The 100 estimates under each of the three designs. Clearance is determined
# under any of them, but absorption rate and the interindividual variances are
# determined by the sampling times. The singular design (sparse2) has many
# values that ran off to a boundary.
par(mfrow = c(1, 3), mar = c(4, 4, 2, 1))
for (v in c("CL", "KA", "OM_KA")) {
  boxplot(ok[[v]] ~ factor(ok$DESIGN, levels = c("rich", "sparse3", "sparse2")), col = "#12366933",
          xlab = "", ylab = v, main = v, outline = TRUE, pch = 16, cex = 0.5)
  abline(h = psi0[v], col = "#B2182B", lty = 2)
}
