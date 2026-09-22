# Forest plot of the covariate effect. At the 5th, 25th, 75th and 95th
# percentiles of weight, plot how many times the reference (1.5 kg) clearance
# is, with an interval from the asymptotic SE. What a report and a reviewer
# actually read is not the exponent but this ratio (the third question of Ch 19).
wt  <- quantile(d$WT[!duplicated(d$ID)], c(0.05, 0.25, 0.75, 0.95))
b   <- est[["THETA5"]]; sb <- se[["THETA5"]]
ratio <- function(w, bb) (w / 1.5)^bb
lo <- ratio(wt, b - 1.96 * sb); hi <- ratio(wt, b + 1.96 * sb)   # lighter than the reference flips it
tab <- data.frame(weight = round(wt, 2), ratio = round(ratio(wt, b), 2),
                  lower = round(pmin(lo, hi), 2), upper = round(pmax(lo, hi), 2))
tab
par(mar = c(4, 6, 1, 1))
plot(tab$ratio, seq_along(wt), xlim = c(0.2, 3), log = "x", yaxt = "n", pch = 16,
     col = "#123669", xlab = "CL ratio (reference 1.5 kg = 1)", ylab = "")
segments(tab$lower, seq_along(wt), tab$upper, seq_along(wt), lwd = 2, col = "#123669")
axis(2, seq_along(wt), paste0(round(wt, 2), " kg"), las = 1)
abline(v = 1, lty = 2); rect(0.8, 0, 1.25, 5, col = "#12366911", border = NA)   # 0.8-1.25
