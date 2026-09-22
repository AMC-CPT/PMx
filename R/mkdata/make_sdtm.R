# =====================================================================
#  R/mkdata/make_sdtm.R
#
#  Builds the practice data of Ch 5. Starting from the public phenobarbital
#  neonate data (Beal & Sheiner, a NONMEM distribution example), it
#  **decomposes it backwards** into SDTM-style source domains (DM/EX/PC/VS/LB).
#
#  Why do it this way.
#    Ch 5 teaches the process of merging scattered domains, but the public
#    data exists only as an already-merged NONMEM dataset. Decomposing it and
#    merging it again gives **data whose right answer is known**, so readers
#    can verify their own pipeline. This is the book's principle of "test with data whose truth is known".
#
#  The decomposition deliberately plants the problems Ch 5 will teach.
#    (1) weight lives in VS, not DM, and is time-varying, measured per visit
#    (2) the nominal sampling time (PC) differs from the actual (PC_COLL)
#    (3) a censored laboratory value "<0.2" is present as a string
#    (4) the upper limit of normal differs by site, as does the unit notation
#    (5) pre-dose sampling records (DV=0) are present
#    (6) column names and separators differ from study to study
#
#  Run:     Rscript R/mkdata/make_sdtm.R
#  Output:  data/pheno.csv          (the answer dataset)
#           data/sdtm/*.csv         (the source domains)
#
#  Note: the SDTM domains are **an artefact made by this book**. They are not
#        real trial data; the provenance of the original is given in data/README.md.
# =====================================================================

set.seed(20260914)
RNGkind()   # leave the three values needed to reproduce on the console

OUT <- "data"
dir.create(file.path(OUT, "sdtm"), recursive = TRUE, showWarnings = FALSE)

# ---------------------------------------------------------------------
# 1. Read the original: strip the trailing FIN marker
#
#    The original is util/PHENO of a default NONMEM installation (nm75g64 and
#    so on for other versions). Without it, the committed data/pheno.csv is
#    used instead. That file was produced by the write.csv below, so the
#    content is the same and **this whole script runs on a machine without    NONMEM.** In practice there is no need to re-run it (the artefacts are committed).
# ---------------------------------------------------------------------
SRC <- c("C:/nm76g64/util/PHENO", "C:/nm75g64/util/PHENO", "data/PHENO")
SRC <- SRC[file.exists(SRC)]

if (length(SRC)) {
  message("original: ", SRC[1])
  ln <- readLines(SRC[1])
  ln <- ln[nzchar(trimws(ln)) & !grepl("FIN", ln)]
  d <- read.table(text = ln, header = FALSE, na.strings = ".",
                  col.names = c("ID", "TIME", "AMT", "WT", "APGR", "DV", "MDV", "EVID"))
} else {
  message("No original (util/PHENO). Using the committed data/pheno.csv instead.")
  d <- read.csv(file.path(OUT, "pheno.csv"), na.strings = ".")
}
stopifnot(nrow(d) == 744, length(unique(d$ID)) == 59, sum(d$MDV == 0) == 155)

write.csv(d, file.path(OUT, "pheno.csv"), row.names = FALSE, na = ".")
message("data/pheno.csv  (answer): ", nrow(d), " rows / ", length(unique(d$ID)), " subjects")

# ---------------------------------------------------------------------
# 2. Turn the time axis back into date-times
#    TIME is hours from the first dose. Each subject is taken to have been    admitted on a different day.
# ---------------------------------------------------------------------
ids <- sort(unique(d$ID))
start0 <- as.POSIXct("2026-01-05 08:00", tz = "UTC")
subj_start <- setNames(start0 + (seq_along(ids) - 1) * 86400 * 3, ids)

d$DTC <- subj_start[as.character(d$ID)] + d$TIME * 3600
fmt <- function(x) format(x, "%Y-%m-%dT%H:%M")

# USUBJID and site: allocate across three sites
site <- setNames(sprintf("%02d", (ids - 1) %% 3 + 1), ids)
usub <- setNames(sprintf("PHN-%s-%03d", site[as.character(ids)], ids), ids)
d$USUBJID <- usub[as.character(d$ID)]
d$SITEID  <- site[as.character(d$ID)]

# ---------------------------------------------------------------------
# 3. DM: only what does not change through the study. Weight is not here (the point of Ch 5)
# ---------------------------------------------------------------------
first <- !duplicated(d$ID)
dm <- data.frame(
  STUDYID  = "PHN-001",
  USUBJID  = d$USUBJID[first],
  SUBJID   = d$ID[first],
  SITEID   = d$SITEID[first],
  SEX      = ifelse(d$ID[first] %% 2 == 0, "F", "M"),
  RACE     = ifelse(d$ID[first] %% 5 == 0, "WHITE", "ASIAN"),
  ARMCD    = "PHENO",
  BRTHDTC  = format(subj_start[as.character(d$ID[first])] - 86400 * 2, "%Y-%m-%d"),
  RFSTDTC  = fmt(d$DTC[first]),
  APGAR    = d$APGR[first],       # measured once at birth, so it belongs in DM
  stringsAsFactors = FALSE
)
write.csv(dm, file.path(OUT, "sdtm/dm.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
# 4. EX: dosing records
# ---------------------------------------------------------------------
e <- d[d$EVID == 1, ]
ex <- data.frame(
  STUDYID = "PHN-001", USUBJID = e$USUBJID,
  EXTRT   = "PHENOBARBITAL",
  EXDOSE  = e$AMT, EXDOSU = "mg",
  EXROUTE = "INTRAVENOUS",
  EXSTDTC = fmt(e$DTC), EXENDTC = fmt(e$DTC),
  stringsAsFactors = FALSE
)
write.csv(ex, file.path(OUT, "sdtm/ex.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
# 5. PC: concentrations, recorded at the nominal time (the actual sampling time is kept separately)
#    A pre-dose zero record is planted: the drug is exogenous, so it is zero    a priori.
# ---------------------------------------------------------------------
o <- d[d$MDV == 0, ]
LLOQ <- 2.0
pc_main <- data.frame(
  USUBJID = o$USUBJID,
  PCTESTCD = "PHENO", PCTEST = "Phenobarbital",
  # The nominal time is recorded on a 30-minute grid (up to 15 minutes from
  # the truth)
  PCDTC = fmt(as.POSIXct(round(as.numeric(o$DTC) / 1800) * 1800,
                         origin = "1970-01-01", tz = "UTC")),
  ACTDTC = fmt(o$DTC),            # actual sampling time = truth; exported only as pc_coll
  PCSTRESN = o$DV, PCSTRESU = "mg/L", PCLLOQ = LLOQ,
  PCSTAT = "", PCREASND = "",
  stringsAsFactors = FALSE
)
# Pre-dose sampling: DV=0 at each subject's first dosing time (nominal and actual coincide)
pre <- data.frame(
  USUBJID = dm$USUBJID,
  PCTESTCD = "PHENO", PCTEST = "Phenobarbital",
  PCDTC = fmt(d$DTC[first]), ACTDTC = fmt(d$DTC[first]),
  PCSTRESN = 0, PCSTRESU = "mg/L", PCLLOQ = LLOQ,
  PCSTAT = "", PCREASND = "PREDOSE",
  stringsAsFactors = FALSE
)
pc <- rbind(pre, pc_main)
pc <- pc[order(pc$USUBJID, pc$PCDTC), ]

# The actual sampling time lives in a separate domain and **that is the
# truth**. The time in PC is only the nominal time rounded to a 30-minute
# grid. So when the assembly of Ch 5 uses the actual time it matches pheno.csv exactly, and with the nominal time it is out by up to 15 minutes. The difference is visible to the eye.
coll <- data.frame(
  USUBJID = pc$USUBJID, PCTESTCD = pc$PCTESTCD,
  PCDTC_PLANNED = pc$PCDTC, PCDTC_ACTUAL = pc$ACTDTC,
  stringsAsFactors = FALSE
)
write.csv(coll, file.path(OUT, "sdtm/pc_coll.csv"), row.names = FALSE)

pc$ACTDTC <- NULL
write.csv(pc, file.path(OUT, "sdtm/pc.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
# 6. VS: weight. Measured per visit and time-varying; the baseline equals the WT of the original data.
#    Tab-separated with different column names, so that Ch 5 has to fix it.
# ---------------------------------------------------------------------
wt0 <- setNames(d$WT[first], d$ID[first])
vs <- do.call(rbind, lapply(ids, function(i) {
  rng <- range(d$TIME[d$ID == i])
  vt <- unique(c(0, seq(0, rng[2], by = 72)))            # every three days
  gain <- 1 + 0.004 * (vt / 24)                          # neonatal weight gain
  data.frame(USUBJID = unname(usub[as.character(i)]),
             VISIT = ifelse(vt == 0, "DAY 1", paste0("DAY ", round(vt / 24) + 1)),
             VSTESTCD = "WEIGHT",
             VSDTC = fmt(subj_start[as.character(i)] + vt * 3600),
             VSORRES = unname(round(wt0[as.character(i)] * gain, 2)),
             VSORRESU = "kg", stringsAsFactors = FALSE)
}))
write.table(vs, file.path(OUT, "sdtm/vs.txt"), sep = "\t",
            row.names = FALSE, quote = FALSE)

# ---------------------------------------------------------------------
# 7. LB: serum creatinine. Censored values and site-specific limits are planted.
# ---------------------------------------------------------------------
lb <- do.call(rbind, lapply(ids, function(i) {
  rng <- range(d$TIME[d$ID == i])
  lt <- unique(c(0, seq(0, rng[2], by = 96)))
  v <- round(pmax(0.1, rnorm(length(lt), 0.35, 0.12)), 2)
  orres <- ifelse(v < 0.2, "<0.2", format(v, trim = TRUE))  # censored values are strings
  data.frame(USUBJID = unname(usub[as.character(i)]),
             SITEID = unname(site[as.character(i)]),
             LBTESTCD = "CREAT",
             LBDTC = fmt(subj_start[as.character(i)] + lt * 3600),
             LBORRES = orres,
             LBORRESU = unname(ifelse(site[as.character(i)] == "03", "umol/L", "mg/dL")),
             stringsAsFactors = FALSE)
}))
# Site 03 uses a different unit, and the values are recorded in it (1 mg/dL = 88.4 umol/L)
i3 <- lb$SITEID == "03" & lb$LBORRES != "<0.2"
lb$LBORRES[i3] <- format(round(as.numeric(lb$LBORRES[i3]) * 88.4, 1), trim = TRUE)
lb$LBORRES[lb$SITEID == "03" & lb$LBORRES == "<0.2"] <- "<17.7"
write.csv(lb, file.path(OUT, "sdtm/lb.csv"), row.names = FALSE)

# Upper limit of normal by site: both the value and the unit differ
lbnorm <- data.frame(
  SITEID = c("01", "02", "03"), LBTESTCD = "CREAT",
  LBORNRLO = c(0.10, 0.10, 8.8), LBORNRHI = c(0.50, 0.60, 53.0),
  LBORRESU = c("mg/dL", "mg/dL", "umol/L"), stringsAsFactors = FALSE
)
write.csv(lbnorm, file.path(OUT, "sdtm/lb_norm.csv"), row.names = FALSE)

# ---------------------------------------------------------------------
message("\ndata/sdtm/ written:")
for (f in list.files(file.path(OUT, "sdtm"), full.names = TRUE)) {
  message(sprintf("  %-16s %5d rows", basename(f),
                  length(readLines(f)) - 1L))
}
message("\nFor comparison against the answer: data/pheno.csv (", nrow(d), " rows)")
