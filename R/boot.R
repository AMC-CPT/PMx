# =====================================================================
#  R/boot.R  -  nonparametric bootstrap (Ch 14).  Licensed machines only.
#  Run from the repository root:   Rscript R/boot.R [replicates]
#
#  Resample subjects with replacement and refit the same model. The spread
#  of the 200 sets of estimates so obtained is the parameter uncertainty.
#  Unlike the asymptotic standard error it assumes neither normality nor a large sample.
#
#  The result comes down to one small file, nm/boot/boot.csv. With that file
#  alone the R code of Ch 14 runs without NONMEM.
# =====================================================================
if (!dir.exists("R/snippets")) stop("Run from the repository root.")
NREP <- as.integer(c(commandArgs(trailingOnly = TRUE), "200")[1])

d   <- read.csv("data/pheno-nm.csv", colClasses = c(DAT2 = "character",
                                                    TIME = "character"))
uid <- unique(d$ID)
rec <- split(seq_len(nrow(d)), factor(d$ID, levels = uid))   # row numbers per subject
nrec <- lengths(rec)

dir.create("nm/boot", showWarnings = FALSE)
set.seed(20260916)
RNGkind()                              # the three values needed to reproduce (Ch 3)

#  The unit of resampling is **the subject, not the record**. One person's
#  observations are not independent, so shuffling records breaks the correlation structure.
#
#  And after drawing, **renumber**. When the same person is drawn twice and
#  the original ID is left alone, NONMEM reads it as one person's records.
#  Only one ETA is assigned and interindividual variability is underestimated (the pitfall box of Ch 14).
make_boot <- function() {
  drawn <- sample(uid, length(uid), replace = TRUE)
  b <- d[unlist(rec[as.character(drawn)]), ]
  b$ID <- rep(seq_along(drawn), nrec[as.character(drawn)])
  rownames(b) <- NULL

  # ---- Always check after drawing ------------------------------------
  stopifnot(nrow(b) == sum(nrec[as.character(drawn)]),
            length(unique(b$ID)) == length(uid),          # still 59 subjects?
            !is.unsorted(b$ID),                           # is each person contiguous?
            identical(as.vector(table(b$ID)),
                      as.vector(nrec[as.character(drawn)])))  # do the row counts match?
  list(data = b, drawn = drawn)
}

read_run <- function(rundir, model) {
  f <- file.path(rundir, paste0(model, ".ext"))
  if (!file.exists(f)) return(NULL)
  e <- read.table(f, skip = 1, header = TRUE)
  x <- e[e$ITERATION == -1000000000, ]
  list(OFV = x$OBJ, T1 = x$THETA1, T2 = x$THETA2, T3 = x$THETA3,
       T4 = x$THETA4, T5 = x$THETA5, T6 = x$THETA6,
       O11 = x$OMEGA.1.1., O21 = x$OMEGA.2.1., O22 = x$OMEGA.2.2.)
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

cols <- c("OFV", paste0("T", 1:6), "O11", "O21", "O22")
res  <- data.frame(REP = seq_len(NREP))
for (k in cols) res[[k]] <- NA_real_
res$NOBS <- NA_integer_      # the number of observations differs per resample
res$NUNIQ <- NA_integer_     # how many of the original 59 were drawn
res$TERM <- NA_character_

t0 <- Sys.time()
for (i in seq_len(NREP)) {
  bb <- make_boot()
  write.csv(bb$data, "data/_boot.csv", row.names = FALSE, quote = FALSE)
  res$NOBS[i]  <- sum(bb$data$MDV == 0)
  res$NUNIQ[i] <- length(unique(bb$drawn))

  suppressWarnings(system2("Rscript", c("R/runnm.R", "boot"),
                           stdout = NULL, stderr = NULL))
  v <- read_run("nm/boot.R76", "boot")
  if (!is.null(v)) for (k in cols) res[[k]][i] <- v[[k]]
  res$TERM[i] <- term_of("nm/boot.R76", "boot")
  if (i %% 10 == 0)
    message(sprintf("  %3d/%d  elapsed %s", i, NREP,
                    format(round(Sys.time() - t0))))
}

write.csv(res, "nm/boot/boot.csv", row.names = FALSE, quote = FALSE)
unlink(c("data/_boot.csv", "nm/boot.R76"), recursive = TRUE)
message(sprintf("\n%d replicates, %d with no artefact, total %s", NREP, sum(is.na(res$OFV)),
                format(round(Sys.time() - t0))))
print(table(res$TERM, useNA = "ifany"))
message("written to nm/boot/boot.csv.  next: Rscript R/build.R")
