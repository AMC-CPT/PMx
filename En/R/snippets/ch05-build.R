# Now assemble. Dosing records and observation records are set on one time axis.
# ID is renumbered as the integer NONMEM will use; the key (USUBJID) stays in
# the SUBJID column.
nm <- build_nm_dataset(DM = dm, EX = ex, PC = pc, dose_cmt = 1L,
                       id_func = function(u) as.integer(sub("^.*-", "", u)))
dim(nm)

# Count the records. The 59 pre-dose samples stay with MDV=1 and are not
# counted as observations.
table(record = ifelse(nm$AMT > 0, "dose", "sample"), MDV = nm$MDV)
head(nm, 3)
