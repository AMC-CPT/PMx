# The simultaneous fit (wf201) beside the IPP (wf200). Only the PD parameters
# are compared. The wall-clock time is what runnm.R left at the end of nmfe.log.
wall <- function(m) as.numeric(sub("wall seconds: ", "",
                    grep("wall seconds", readLines(nmf(m, "nmfe.log")), value = TRUE)))
si <- fin("wf201")
key2 <- c(BASE = "THETA4", KOUT = "THETA5", C50 = "THETA6", add.SD = "THETA8",
          OM_BASE = "OMEGA.4.4.", OM_KOUT = "OMEGA.5.5.", OM_C50 = "OMEGA.6.6.")
key1 <- c(BASE = "THETA1", KOUT = "THETA2", C50 = "THETA3", add.SD = "THETA4",
          OM_BASE = "OMEGA.1.1.", OM_KOUT = "OMEGA.2.2.", OM_C50 = "OMEGA.3.3.")
data.frame(truth = signif(truth[c("BASE", "KOUT", "C50", "ADDPD", "OM_BASE", "OM_KOUT", "OM_C50")], 3),
           IPP = signif(pd$f[key1], 3), RSE = round(100 * pd$s[key1] / abs(pd$f[key1]), 1),
           simultaneous = signif(si$f[key2], 3), RSE = round(100 * si$s[key2] / abs(si$f[key2]), 1),
           row.names = names(key1))
c(OFV.PK = round(pk$f[["OBJ"]], 1), OFV.IPP = round(pd$f[["OBJ"]], 1),
  sum = round(pk$f[["OBJ"]] + pd$f[["OBJ"]], 1), OFV.simultaneous = round(si$f[["OBJ"]], 1))
c(sec.PK = wall("wf100"), sec.IPP = wall("wf200"), sec.simultaneous = wall("wf201"))
