# This is the symptom: a covariate that should be time-invariant takes several
# values within one person.
nval <- function(d) tapply(d$WT, d$ID, function(x) length(unique(x)))
rbind(by.merge = nval(bad), by.match = nval(good))

# So check two things **immediately after** shuffling. If the values slipped,
# it stops here.
check_perm <- function(d, orig) {
  stopifnot(all(tapply(d$WT, d$ID, function(x) length(unique(x))) == 1),
            identical(sort(unique(d$WT)), sort(unique(orig$WT))))
  "passed"
}
c(by.match = check_perm(good, ex))
c(by.merge = tryCatch(check_perm(bad, ex), error = function(e) "failed"))
