# The baseline weight, chosen as time-invariant, is finished by spreading one
# value over every record.
nm$WT <- vsb$BWT[match(nm$SUBJID, vsb$SUBJID)]

# Make the same weight time-varying as well. Gaps are filled by LOCF.
nm <- merge_cov_locf(nm, vsw, value_cols = "BWT",  time_col = "VSDTC",
                     median_fb = FALSE)
nm <- merge_cov_locf(nm, lbc, value_cols = "CREA", time_col = "LBDTC",
                     median_fb = FALSE)
stopifnot(!anyNA(nm$WT), !anyNA(nm$BWT), !anyNA(nm$CREA))   # no gap may remain

# How different are the two choices? The data does not settle it. A person
# chooses, and writes the choice down in advance.
table(weight = ifelse(nm$BWT == nm$WT, "same as baseline", "differs from baseline"))
c(max.vs.baseline = round(max(nm$BWT / nm$WT), 3))
