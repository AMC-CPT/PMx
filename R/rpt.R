# =====================================================================
#  R/rpt.R  -  randomization test (Ch 13).  Licensed machines only.
#  Run from the repository root:   Rscript R/rpt.R [replicates]
#
#  Shuffle weight at random among the subjects, refit the same covariate
#  model, and build the null distribution of dOFV. Once shuffled, weight
#  carries no information; the dOFV arising from it is the size obtainable by chance.
#
#  The result comes down to one small file, nm/rpt/rpt.csv. With that file
#  alone the R code of Ch 13 runs without NONMEM.
# =====================================================================
if (!dir.exists("R/snippets")) stop("Run from the repository root.")
NREP <- as.integer(c(commandArgs(trailingOnly = TRUE), "200")[1])

d <- read.csv("data/pheno-nm.csv", colClasses = c(DAT2 = "character",
                                                  TIME = "character"))
uid <- unique(d$ID)
wt  <- d$WT[match(uid, d$ID)]          # one per subject; time-invariant
stopifnot(length(wt) == length(uid), !anyNA(wt))

dir.create("nm/rpt", showWarnings = FALSE)
set.seed(20260915)
RNGkind()                              # the three values needed to reproduce (Ch 3)

#  Decide in advance what to keep per permutation. Keeping only the OFV
#  leaves no way to ask later why the tail of the null distribution is heavy (Ch 13). Record the exponents and the termination status as well.
read_run <- function(rundir, model) {
  f <- file.path(rundir, paste0(model, ".ext"))
  if (!file.exists(f)) return(list(OFV = NA_real_, T5 = NA_real_, T6 = NA_real_))
  e <- read.table(f, skip = 1, header = TRUE)
  x <- e[e$ITERATION == -1000000000, ]
  list(OFV = x$OBJ, T5 = x$THETA5, T6 = x$THETA6)
}
term_of <- function(rundir, model) {
  f <- file.path(rundir, paste0(model, ".lst"))
  if (!file.exists(f)) return("NO OUTPUT")
  x <- readLines(f, warn = FALSE)
  if (any(grepl("MINIMIZATION SUCCESSFUL", x)))       "SUCCESS"
  else if (any(grepl("ROUNDING ERRORS", x)))          "ROUNDING"
  else if (any(grepl("MINIMIZATION TERMINATED", x)))  "TERMINATED"
  else                                                "OTHER"
}

res <- data.frame(REP = seq_len(NREP), OFV = NA_real_, T5 = NA_real_,
                  T6 = NA_real_, TERM = NA_character_)
t0  <- Sys.time()
for (i in seq_len(NREP)) {
  # ---- Shuffle --------------------------------------------------------
  #  Do not assume ID is sorted. match() preserves row order.
  #  merge() reorders by the join key, so a shuffled value lands on a
  #  different row (the real error of Analects 22.C, reproduced in Ch 13).
  perm <- data.frame(ID = uid, WT = sample(wt))
  p <- d
  p$WT <- perm$WT[match(p$ID, perm$ID)]

  # ---- Always check after shuffling ------------------------------------
  n1 <- tapply(p$WT, p$ID, function(x) length(unique(x)))
  stopifnot(all(n1 == 1),                                   # still time-invariant?
            identical(sort(unique(p$WT)), sort(unique(d$WT))))  # same set of values?

  write.csv(p, "data/_perm.csv", row.names = FALSE, quote = FALSE)
  suppressWarnings(system2("Rscript", c("R/runnm.R", "rpt"),
                           stdout = NULL, stderr = NULL))
  v <- read_run("nm/rpt.R76", "rpt")
  res$OFV[i] <- v$OFV; res$T5[i] <- v$T5; res$T6[i] <- v$T6
  res$TERM[i] <- term_of("nm/rpt.R76", "rpt")
  if (i %% 10 == 0)
    message(sprintf("  %3d/%d  elapsed %s", i, NREP,
                    format(round(Sys.time() - t0))))
}

write.csv(res, "nm/rpt/rpt.csv", row.names = FALSE, quote = FALSE)
unlink(c("data/_perm.csv", "nm/rpt.R76"), recursive = TRUE)
message(sprintf("\n%d replicates, %d failed, total %s", NREP, sum(is.na(res$OFV)),
                format(round(Sys.time() - t0))))
message("written to nm/rpt/rpt.csv.  next: Rscript R/build.R")
