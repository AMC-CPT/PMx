# DM has one row per subject and holds only what does not change through the
# study. Weight is not here.
names(DM)

# The key joining the domains is USUBJID; SUBJID is unique within a site only.
# nmw's assembly function requires the key column to be called SUBJID, so
# USUBJID goes into it.
DM$SUBJID <- DM$USUBJID
DM$SEX    <- code_sex(DM$SEX)      # M=0, F=1. Fix the coding; do not trust the document
DM$APGR   <- as.numeric(DM$APGAR)

dm <- DM[, c("SUBJID", "SITEID", "SEX", "APGR")]
head(dm, 3)
