# CWRES against time. A bend means the structure is wrong (Section 7.7).
sd1 <- read.table(nmf("140iv2", "sdtab"), skip = 1, header = TRUE)
sd2 <- read.table(nmf("200iv2", "sdtab"), skip = 1, header = TRUE)
sd1 <- sd1[sd1$MDV == 0, ]; sd2 <- sd2[sd2$MDV == 0, ]
yl <- range(c(sd1$CWRES, sd2$CWRES))
par(mfrow = c(1, 2), mar = c(4, 4, 2.2, 1))
for (s in list(list(d = sd1, t = "1 compartment (140iv2)"),
               list(d = sd2, t = "2 compartments (200iv2)"))) {
  plot(s$d$TIME, s$d$CWRES, log = "x", pch = 16, col = "#12366955", ylim = yl,
       xlab = "time (h)", ylab = "CWRES", main = s$t)
  abline(h = 0, lty = 3)
  lines(lowess(s$d$TIME, s$d$CWRES), lwd = 2)
}
