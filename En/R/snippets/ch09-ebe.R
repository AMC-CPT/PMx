# Run artefacts live in one folder per model: nm/<model>.R76/ (Ch 3)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# A covariate search begins by plotting the EBEs against the covariates.
# If the base model's ETA leans along some covariate, the share that covariate
# would explain is at present being carried by the ETA.
pa <- read.table(nmf("100base", "patab"), skip = 1, header = TRUE)
co <- read.table(nmf("100base", "cotab"), skip = 1, header = TRUE)
s  <- merge(pa[!duplicated(pa$ID), ], co[!duplicated(co$ID), ], by = "ID")

round(cor(s[, c("ETA1", "ETA2")], s[, c("WT", "CREA", "APGR")]), 3)
