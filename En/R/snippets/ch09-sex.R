# A negative control. In this teaching dataset SEX is a **fake covariate
# assigned by the parity of the subject number** (data/README.md). We know it
# carries no information. A search procedure that cannot filter it out is a
# procedure that cannot be trusted.
drop <- ofv("108wt") - ofv("109sex")          # how far adding it brought the OFV down
c(dOFV = round(drop, 2), threshold = 3.84,
  p = round(pchisq(drop, df = 1, lower.tail = FALSE), 3))

# Look at the effect size alongside. Not significant, and small as well.
c(SEX.effect = round(fin("109sex")[["THETA7"]], 3))
