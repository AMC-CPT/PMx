# The parameter table of the final model: the report's table, built from this
# book's artefacts alone. The point estimates and RSEs come from the .ext, the
# resampling intervals from the boot.csv of Ch 14, and the likelihood intervals
# from its llp.csv. The column names say which interval is which.
fin <- unlist(e[e$ITERATION == -1000000000, -1])
se  <- unlist(e[e$ITERATION == -1000000001, -1])
key <- c(T1 = "THETA1", T2 = "THETA2", T3 = "THETA3", T4 = "THETA4",
         T5 = "THETA5", T6 = "THETA6",
         O11 = "OMEGA.1.1.", O21 = "OMEGA.2.1.", O22 = "OMEGA.2.2.")
b  <- read.csv("nm/boot/boot.csv")
bq <- sapply(names(key), function(k) quantile(b[[k]], c(0.025, 0.975)))
p  <- read.csv("nm/llp/llp.csv")
p$dOFV <- p$OFV - fin[["OBJ"]]
p  <- p[p$dOFV >= -0.01, ]; p$dOFV <- pmax(p$dOFV, 0)        # drop the broken points (Ch 14)
li <- function(z, lv = 2 * log(8)) {                          # the 1/8 likelihood interval
  i <- which.min(z$dOFV)
  c(approx(z$dOFV[1:i], z$VALUE[1:i], lv)$y,
    approx(z$dOFV[i:nrow(z)], z$VALUE[i:nrow(z)], lv)$y)
}
lq <- sapply(names(key), function(k)
  if (k %in% p$PAR) li(p[p$PAR == k, ]) else c(NA, NA))

tab <- data.frame(estimate = fin[key], RSE = 100 * se[key] / abs(fin[key]),
                  boot.lo = bq[1, ], boot.hi = bq[2, ], LI.lo = lq[1, ], LI.hi = lq[2, ])
rownames(tab) <- names(key)
signif(tab, 3)

# Three more things go on the interindividual variability rows: the CV, the
# shrinkage, and the fall in omega^2 against the base model.
pa <- read.table(nmf("108wt", "patab"), skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
e0 <- read.table(nmf("100base", "100base.ext"), skip = 1, header = TRUE)
f0 <- unlist(e0[e0$ITERATION == -1000000000, -1])
om <- c("OMEGA.1.1.", "OMEGA.2.2.")
data.frame(row.names = c("CL", "V"), CV = round(100 * sqrt(fin[om]), 1),
           shrinkage = round(100 * (1 - c(sd(pa$ETA1), sd(pa$ETA2)) / sqrt(fin[om])), 1),
           fall = round(100 * (1 - fin[om] / f0[om]), 1))
