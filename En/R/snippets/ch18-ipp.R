# Step 2. Put the individual PK estimates (EBEs) into the data as columns and
# fit the PD alone (IPP, wf200). R/mkdata/make_warf_ipp.R built
# data/warf-ipp.csv from the patab of wf100.
head(read.csv("data/warf-ipp.csv"), 3)
pd <- fin("wf200")
show(pd, c(BASE = "THETA1", KOUT = "THETA2", C50 = "THETA3", add.SD = "THETA4",
           OM_BASE = "OMEGA.1.1.", OM_KOUT = "OMEGA.2.2.", OM_C50 = "OMEGA.3.3."),
     truth[c("BASE", "KOUT", "C50", "ADDPD", "OM_BASE", "OM_KOUT", "OM_C50")])
c(OFV = round(pd$f[["OBJ"]], 2),
  turnover.half.life.h = round(log(2) / pd$f[["THETA2"]], 1))
