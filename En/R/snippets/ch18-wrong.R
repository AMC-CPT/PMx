# Three mechanisms on the same data. Type I (inhibition of synthesis, wf201),
# type IV (stimulation of loss, wf203), effect compartment with a direct Emax
# (wf202). The parameter counts differ, so they are compared by AIC.
mods <- c(wf201 = "indirect I: kin inhibited", wf203 = "indirect IV: kout stimulated",
          wf202 = "effect compartment + Emax")
tab <- t(sapply(names(mods), function(m) {
  r <- fin(m); f <- r$f
  p <- sum(grepl("THETA|OMEGA", names(f)) & f != 0)
  c(OFV = round(f[["OBJ"]], 1), parameters = p, AIC = round(f[["OBJ"]] + 2 * p, 1),
    PD.add.SD = signif(f[["THETA8"]], 3))
}))
data.frame(mechanism = mods, tab, row.names = NULL)
# Is the loss mechanism of wf202 really absent? Look at the termination message.
grep("MINIMIZATION|PROBLEMS", readLines(nmf("wf202", "wf202.lst")), value = TRUE)
