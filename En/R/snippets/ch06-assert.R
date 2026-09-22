# Checking is the business of writing down, as code, what the data must be.
# Count the violations. One check is usually one line. They go undone not
# because they are hard but because they go undone.
check_nm <- function(d) {
  dt  <- as.POSIXct(paste(d$DAT2, d$TIME), format = "%Y-%m-%d %H:%M", tz = "UTC")
  key <- paste(d$ID, dt, d$CMT)
  byid <- function(f) tapply(seq_len(nrow(d)), d$ID, f)
  v <- c(
    "ID not ascending"                = as.integer(is.unsorted(d$ID)),
    "subject records scattered"       = sum(table(rle(d$ID)$values) > 1),
    "datetime is NA"                  = sum(is.na(dt)),
    "TAFD negative"                   = sum(d$TAFD < 0),
    "TAFD goes back within subject"   = sum(unlist(byid(function(i) diff(d$TAFD[i]))) < 0),
    "TAFD disagrees with datetime"    = sum(byid(function(i) {
        e <- (as.numeric(dt[i]) - min(as.numeric(dt[i]))) / 3600 -
             (d$TAFD[i] - min(d$TAFD[i]))
        isTRUE(any(abs(e) > 1e-6)) })),   # an NA dt is already caught above
    "same kind duplicated at a time"  = sum(duplicated(paste(key, d$EVID))),
    "dose first at the same time"     = sum(tapply(seq_along(key), key,
                                            function(i) any(diff(d$EVID[i]) < 0))),
    "dose with AMT not positive"      = sum(d$EVID == 1 & !(d$AMT > 0)),
    "observation with AMT not zero"   = sum(d$EVID == 0 & d$AMT != 0),
    "MDV=0 but DV missing"            = sum(d$MDV == 0 & is.na(d$DV)),
    "covariate missing"               = sum(!complete.cases(d[, c("WT","SEX","APGR","CREA")])),
    "time-invariant covariate varies" = sum(byid(function(i) length(unique(d$WT[i]))) > 1),
    "first observation before first dose" = sum(byid(function(i) {
        o <- d$TAFD[i][d$MDV[i] == 0]; x <- d$TAFD[i][d$EVID[i] == 1]
        length(o) > 0 && length(x) > 0 && min(o) < min(x) }))
  )
  if (all(v == 0)) cat(sprintf("%d checks, no violations\n", length(v))) else print(v[v > 0])
  invisible(v)
}

check_nm(nm)
