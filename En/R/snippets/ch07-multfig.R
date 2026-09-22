# Left: one person's seven days -- three troughs, the final profile, and the
# individual prediction of 130addl. Right: the observations of all 30 against
# time after the last dose (TAD). A residual plot for repeated-dose data must
# be drawn on this axis, not on time after the first dose, for the shape within
# a dosing interval to show.
s <- read.table(nmf("130addl", "sdtab"), skip = 1, header = TRUE)
o <- s[s$MDV == 0, ]
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
z <- o[o$ID == 1, ]
tt <- seq(0, 170, by = 0.25)
p <- fin("130addl")$f; pa <- read.table(nmf("130addl", "patab"), skip = 1, header = TRUE); pa <- pa[pa$ID == 1, ][1, ]
ke <- pa$CL / pa$V
cp <- sapply(tt, function(t) { td <- (0:13) * 12; td <- td[td <= t]
  sum(100 * pa$KA / (pa$V * (pa$KA - ke)) * (exp(-ke * (t - td)) - exp(-pa$KA * (t - td)))) })
plot(tt, cp, type = "l", col = "#123669", xlab = "time after first dose (h)",
     ylab = "concentration (mg/L)",
     main = "ID 1: observations and individual prediction", ylim = c(0, 3.2))
points(z$TIME, z$DV, pch = 16, col = "#B2182B")
o$TAD <- ifelse(o$TIME < 156, o$TIME %% 12, o$TIME - 156)
plot(o$TAD, o$DV, pch = 16, cex = 0.6, col = "#12366966",
     xlab = "time after last dose (h)",
     ylab = "concentration (mg/L)", main = "30 subjects, TAD axis")
