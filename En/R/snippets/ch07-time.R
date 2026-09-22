# Run artifacts live in a folder of their own per model: nm/<model>.R76/ (Ch 3)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# Before looking at the fit, look at whether the data went into NONMEM
# correctly. NONMEM translated DAT2 + TIME into elapsed time by itself (Ch 5).
# Does that translation agree with the TAFD we derived? This is why TAFD was
# carried alongside.
nm <- read.csv("data/pheno-nm.csv",
               colClasses = c(DAT2 = "character", TIME = "character"))
sd <- read.table(nmf("100base", "sdtab"), skip = 1, header = TRUE)

stopifnot(nrow(sd) == nrow(nm))                  # one table row per record?
c(records = nrow(sd), max.difference = max(abs(sd$TIME - nm$TAFD)))
