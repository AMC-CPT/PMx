# =====================================================================
#  R/mkdata/make_warf_ipp.R  -  PD data for IPP (individual PK parameters)
#  Run from the repository root:   Rscript R/mkdata/make_warf_ipp.R
#
#  The IPP method of sequential PK/PD (Zhang, Beal and Sheiner 2003) puts the
#  individual estimates (EBEs) of the PK model into the data as columns and
#  fits the PD alone. So this script **depends on the run artefacts of wf100  (its patab)**; wf100 must be run first.
#
#  Result: data/warf-ipp.csv (ID TIME DV MDV EVID DOSE IKA ICL IV). PCA records only.
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")
pt <- "nm/wf100.R76/patab"
if (!file.exists(pt)) stop("nm/wf100.R76/patab is missing. Run Rscript R/runnm.R wf100 first")

pa <- read.table(pt, skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), c("ID", "KA", "CL", "V")]
names(pa) <- c("ID", "IKA", "ICL", "IV")

d <- read.csv("data/warf-sim.csv", na.strings = ".")
pd <- d[d$DVID == 2, c("ID", "TIME", "DV", "MDV", "EVID")]
dose <- d[d$EVID == 1, c("ID", "AMT")]; names(dose)[2] <- "DOSE"
pd <- merge(merge(pd, dose, by = "ID"), pa, by = "ID")
pd <- pd[order(pd$ID, pd$TIME), c("ID", "TIME", "DV", "MDV", "EVID", "DOSE", "IKA", "ICL", "IV")]
pd$IKA <- signif(pd$IKA, 5); pd$ICL <- signif(pd$ICL, 5); pd$IV <- signif(pd$IV, 5)
write.csv(pd, "data/warf-ipp.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/warf-ipp.csv: %d rows, %d subjects. Individual CL range %.3f-%.3f L/h\n",
            nrow(pd), length(unique(pd$ID)), min(pd$ICL), max(pd$ICL)))
