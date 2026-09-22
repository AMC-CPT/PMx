# Tumor volume in 20 animals. A straight line on the log axis is exponential
# growth; a bend means the growth rate falls with time. It bends. So the
# exponential model drops out of the candidates.
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(DV ~ TIME, llc, type = "n", xlab = "days after implantation",
     ylab = expression(volume~(mm^3)), main = "linear axis")
for (i in split(llc, llc$ID)) lines(i$TIME, i$DV, col = "#12366966")
plot(DV ~ TIME, llc, type = "n", log = "y", xlab = "days after implantation", ylab = "",
     main = "log axis")
for (i in split(llc, llc$ID)) lines(i$TIME, i$DV, col = "#12366966")
