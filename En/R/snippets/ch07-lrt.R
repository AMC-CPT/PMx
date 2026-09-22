# Reduce the full block to a diagonal and one covariance drops out. Look at the
# OFV hierarchy. The two models are nested, so the OFV difference approximately
# follows a chi-square (LRT).
d <- fin("101diag")
dOFV <- d[["OBJ"]] - b[["OBJ"]]

c(full = round(b[["OBJ"]], 2), diag = round(d[["OBJ"]], 2),
  dOFV = round(dOFV, 2), df = 1)
c(p = signif(pchisq(dOFV, df = 1, lower.tail = FALSE), 3))

# How do the two variances change when we fall back to a diagonal?
round(rbind(full = b[c("OMEGA.1.1.", "OMEGA.2.2.")],
            diag = d[c("OMEGA.1.1.", "OMEGA.2.2.")]), 4)
