# Model lineage. SumOut reads the P: and F: of each $PROB and makes a table of
# them (Ch 4). What it reads is the FCON in the run folder, which is why that
# file is kept.
owd <- setwd("nm")
mdl <- SumOut(FileExt = ".ctl", RunExt = ".R76", OutExt = ".lst")
setwd(owd)

# A simulation-only run (Ch 12) does no estimation, so it has no OFV. Drop it
# from the lineage. This chapter looks only at the phenobarbital lineage of
# Part III (100-109); models of other chapters belong to their own chapters.
mdl <- mdl[!is.na(mdl$OFV) & grepl("^10[0-9]", mdl$OutName), ]
mdl[, c("OutName", "Parent", "Formula", "OFV", "Parameter", "AICc")]
