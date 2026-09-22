# The OFV curve from fixing one parameter and re-estimating the rest (R/llp.R).
# Where dOFV reaches 3.84 is the end of the 95 % interval (1 df).
p    <- read.csv("nm/llp/llp.csv")
base <- as.numeric(e[e$ITERATION == -1000000000, "OBJ"])
p$dOFV <- p$OFV - base

# A profile OFV cannot be below the overall minimum. If it is, the run broke.
# (At the optimum itself numerical error makes it about 1e-6 low, so allow that.)
table(termination = p$TERM, broken = p$dOFV < -0.01)
p <- p[p$dOFV >= -0.01, ]
p$dOFV <- pmax(p$dOFV, 0)

# Find where it crosses 3.84 on each side of the floor, by linear interpolation.
cross <- function(x, y, lv = qchisq(0.95, 1)) {
  i <- which.min(y)
  c(lower = approx(y[1:i], x[1:i], lv)$y,
    upper = approx(y[i:length(y)], x[i:length(y)], lv)$y)
}
llp <- t(sapply(split(p, p$PAR), function(z) cross(z$VALUE, z$dOFV)))
round(llp, 4)

# NA means it never reached 3.84 even at the end of the grid. Look at that end.
t(sapply(split(p, p$PAR), function(z)
  c(grid.bottom = min(z$VALUE), dOFV.there = round(z$dOFV[which.min(z$VALUE)], 2))))
