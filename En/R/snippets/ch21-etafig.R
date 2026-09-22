# The clearance ETA against PMA. In the model without maturation (left) the
# neonates' ETA all lean one way: what the model did not explain has stayed in
# the random effect. Put maturation in (right) and it goes.
eta <- function(m) { p <- read.table(nmf(m, "patab"), skip = 1, header = TRUE); p[!duplicated(p$ID), "ETA1"] }
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
for (z in list(list("ped100", "size only"), list("ped101", "size + maturation"))) {
  e <- eta(z[[1]])
  plot(s$PMA, e, log = "x", pch = 16, col = c("#B2182B", "#4DAF4A", "#123669", "grey40")[s$GRP],
       xlab = "PMA (weeks, log axis)", ylab = "ETA(CL)", main = z[[2]], ylim = c(-2.5, 1))
  lines(lowess(log(s$PMA), e, f = 0.5)$x |> exp(), lowess(log(s$PMA), e, f = 0.5)$y,
        col = "grey30", lwd = 2)
  abline(h = 0, lty = 3)
}
