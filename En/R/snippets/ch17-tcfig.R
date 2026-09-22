# The time course of NRS by arm. The placebo arm comes down too. That is
# natural recovery, and the drug effect is the difference from placebo. Without
# a placebo arm that difference cannot be known.
n <- d[d$DVID == 2, ]
m <- tapply(n$DV, list(n$TIME, n$ARM), mean)
par(mar = c(4, 4, 1, 1))
matplot(as.numeric(rownames(m)), m, type = "b", pch = 16, lty = 1, lwd = 1.5,
        col = c("grey40", "#8DA0CB", "#4F6DB0", "#123669"),
        xlab = "time (h)", ylab = "mean NRS", ylim = c(0, 8))
legend("bottomleft", arm, col = c("grey40", "#8DA0CB", "#4F6DB0", "#123669"),
       pch = 16, lty = 1, bty = "n")
