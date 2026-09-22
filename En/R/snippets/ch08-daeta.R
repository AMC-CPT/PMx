# Take out the sensitivities NONMEM integrated and match them against R's own
# integration. 110des writes theophylline with ADVAN13 and, through verbatim
# code, put DAETA(2,j) = dA2/dETA(j) and G(j,1) into a table. We solve the same
# thing in R as eight differential equations: 2 states plus 6 sensitivities.
library(deSolve)
s  <- read.table("nm/110des.R76/sdtab", skip = 1, header = TRUE)
pa <- read.table("nm/110des.R76/patab", skip = 1, header = TRUE)
i  <- 1
p  <- pa[pa$ID == i, ][1, ]                        # this person's parameters (EBEs applied)
ka <- p$KA; cl <- p$CL; v <- p$V; ke <- cl / v
# States y1, y2 and B[j,i] = dA_j/dETA_i.  ETA1->KA, ETA2->CL, ETA3->V.
# dKA/dETA1 = KA, dKE/dETA2 = KE, dKE/dETA3 = -KE (since KE = CL/V).
f <- function(t, y, parms) {
  A1 <- y[1]; A2 <- y[2]
  list(c(-ka * A1,  ka * A1 - ke * A2,
         -ka * A1 - ka * y[3],                 ka * A1 + ka * y[3] - ke * y[4],   # ETA1
         -ka * y[5],                           ka * y[5] - ke * A2 - ke * y[6],   # ETA2
         -ka * y[7],                           ka * y[7] + ke * A2 - ke * y[8]))  # ETA3
}
obs <- s[s$ID == i & s$MDV == 0, ]
amt <- s$AMT[s$ID == i & s$EVID == 1][1]
out <- ode(y = c(amt, 0, 0, 0, 0, 0, 0, 0), times = c(0, obs$TIME), func = f, parms = NULL,
           rtol = 1e-9, atol = 1e-12)[-1, ]
r <- data.frame(TIME = obs$TIME, A2_R = out[, 3], DA21_NM = obs$DA21, DA21_R = out[, 5],
                DA23_NM = obs$DA23, DA23_R = out[, 9])
print(round(r, 4), row.names = FALSE)
# The expression of Ch 8: dF/dETA = (dA/dETA - F * dV/dETA) / V.  V depends on
# ETA3 alone.
F  <- out[, 3] / v
G3 <- (out[, 9] - F * v) / v
c(max.diff.G1 = max(abs(obs$G1 - out[, 5] / v)), max.diff.G3 = max(abs(obs$G3 - G3)))
