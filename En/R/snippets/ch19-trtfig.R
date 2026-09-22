# Observations (points) and typical curves for the control and treated arms.
# The dotted line at day 7 is the start of treatment.
d  <- read.csv("data/tgi-trt.csv")
tt <- seq(0, 21, by = 0.25)
ctl <- V(tt, a)
trt <- ifelse(tt <= 7, V(tt, a), v7 * exp(a * (1 + ef) / b * (exp(-b * 7) - exp(-b * tt))))
par(mar = c(4, 4, 1, 1))
plot(d$TIME, d$DV, pch = 16, cex = 0.6, col = ifelse(d$GRP == 1, "#B2182B66", "#12366966"),
     xlab = "days after implantation", ylab = expression(volume~(mm^3)))
lines(tt, ctl, col = "#123669", lwd = 2); lines(tt, trt, col = "#B2182B", lwd = 2)
abline(v = 7, lty = 3, col = "grey40")
legend("topleft", c("control", "treated"), col = c("#123669", "#B2182B"),
       pch = 16, lwd = 2, bty = "n")
