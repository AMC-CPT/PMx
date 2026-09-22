# Kaplan-Meier curves by arm. The first figure the model has to reproduce.
par(mar = c(4, 4, 1, 1))
plot(km, col = c("#B2182B", "#4DAF4A", "#123669"), lwd = 2, xlab = "months",
     ylab = "proportion event-free", mark.time = TRUE)
legend("bottomleft", c("placebo", "50 mg", "100 mg"),
       col = c("#B2182B", "#4DAF4A", "#123669"), lwd = 2, bty = "n")
abline(h = 0.5, lty = 3)
