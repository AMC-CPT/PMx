# Residuals. What is looked for here is not whether the model is good or bad
# but **a fault in the data preparation**.
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))

plot(obs$TIME, obs$CWRES, pch = 16, col = "#12366966",
     xlab = "time (h)", ylab = "CWRES", main = "against time")
abline(h = c(-2, 0, 2), lty = c(3, 1, 3))
plot(obs$PRED, obs$CWRES, pch = 16, col = "#12366966",
     xlab = "PRED (mg/L)", ylab = "CWRES", main = "against population prediction")
abline(h = c(-2, 0, 2), lty = c(3, 1, 3))
