# What S5 draws: histograms of the ETA and their normal QQ plots. The model
# assumed ETA ~ N(0, OMEGA). Check that assumption with the EBEs, but where
# shrinkage is large this plot shows the shrinkage and not the assumption
# (check the table above before reading it).
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5))
for (k in 1:2) {
  x <- pa[[paste0("ETA", k)]]; om <- sqrt(f[[sprintf("OMEGA.%d.%d.", k, k)]])
  hist(x, breaks = 12, col = "#12366944", border = "white", main = paste0("ETA", k),
       xlab = "", ylab = "", freq = FALSE)
  curve(dnorm(x, 0, om), add = TRUE, col = "#B2182B", lwd = 2)       # normal of the estimated OMEGA
  qqnorm(x, main = paste0("ETA", k, " QQ"), pch = 16, col = "#123669", xlab = "", ylab = "")
  qqline(x, col = "grey40")
}
