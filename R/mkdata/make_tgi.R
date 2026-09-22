# =====================================================================
#  R/mkdata/make_tgi.R  -  the tumour volume data of Ch 19 as NONMEM datasets
#  Run from the repository root:   Rscript R/mkdata/make_tgi.R
#
#  The originals are three preclinical datasets published by Benzekry et al.
#  (2014) with their paper (Ref/growth/dataset/). The three files differ in
#  separator and in column names. This script brings them to one format --  a small revision of Ch 5.
#
#    LLC_sc_CCSB.txt       comma-separated, column Vol.  Lewis lung carcinoma, s.c.
#    LM2-4LUC.txt          tab-separated, column Observation.  LM2-4LUC1 breast
#    MDA-MB-231dTomato.txt tab-separated, column Observation.  fluorescence (photon count)
#
#  Results.
#    data/tgi-llc.csv      ID TIME DV MDV            for $PRED (closed form)
#    data/tgi-llc-ode.csv  ID TIME DV MDV EVID      for ADVAN13. An empty
#                          record (EVID=2) is put at time 0, because the
#                          initial condition of the integration attaches                          there (Ch 19)
#    data/tgi-lm2.csv, data/tgi-mda.csv   same format (exercises)
#  There is no dosing, so there is no AMT.
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")

read_tgi <- function(file, sep, vcol) {
  d <- read.table(file.path("Ref/growth/dataset", file), header = TRUE, sep = sep)
  names(d)[names(d) == vcol] <- "DV"
  d <- d[order(d$ID, d$Time), ]
  data.frame(ID = as.integer(factor(d$ID)), TIME = d$Time, DV = d$DV, MDV = 0L)
}
llc <- read_tgi("LLC_sc_CCSB.txt",       ",",  "Vol")
lm2 <- read_tgi("LM2-4LUC.txt",          "\t", "Observation")
mda <- read_tgi("MDA-MB-231dTomato.txt", "\t", "Observation")

# A volume of 0 is not an observation but "not yet palpable". It cannot be
# logged, nor used as an initial value for a growth model, so it is kept with
# MDV=1 (the rule of Ch 5: flag, do not delete).
for (nm in c("llc", "lm2", "mda")) {
  d <- get(nm)
  d$MDV[d$DV <= 0] <- 1L
  assign(nm, d)
}
# The fluorescence signal spans so many orders of magnitude that initial
# estimates and bounds are hard to set. The unit is taken as 10^8 photons. The unit has changed, not the data.
mda$DV <- mda$DV / 1e8

# For ADVAN13: one EVID=2 record is put in front at time 0 per animal.
ode <- do.call(rbind, lapply(split(llc, llc$ID), function(z)
  rbind(data.frame(ID = z$ID[1], TIME = 0, DV = 0, MDV = 1L, EVID = 2L),
        data.frame(z, EVID = 0L))))
rownames(ode) <- NULL

dir.create("data", showWarnings = FALSE)
write.csv(llc, "data/tgi-llc.csv",     row.names = FALSE, quote = FALSE)
write.csv(ode, "data/tgi-llc-ode.csv", row.names = FALSE, quote = FALSE)
write.csv(lm2, "data/tgi-lm2.csv",     row.names = FALSE, quote = FALSE)
write.csv(mda, "data/tgi-mda.csv",     row.names = FALSE, quote = FALSE)
for (nm in c("llc", "lm2", "mda")) {
  d <- get(nm)
  cat(sprintf("%s: %d animals, %d observations (MDV=1 %d), time %g-%g days, volume %.3g-%.3g\n",
              nm, length(unique(d$ID)), nrow(d), sum(d$MDV), min(d$TIME), max(d$TIME),
              min(d$DV[d$MDV == 0]), max(d$DV[d$MDV == 0])))
}
