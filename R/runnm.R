# =====================================================================
#  R/runnm.R  -  actually runs NONMEM.  Licensed machines only.
#  Run from the repository root:   Rscript R/runnm.R [model ...]
#
#  This repository has one rule.
#
#      Run NONMEM = this script.        A license is needed.
#      Run R      = R/build.R.          Works without NONMEM.
#
#  The run artifacts (.lst .ext .phi and the four tables) are **committed**,
#  so R/build.R and the book build run on a machine without a license.
#  Run this on a licensed machine only when a control stream or data changed.
# =====================================================================
if (!dir.exists("R/snippets"))
  stop("Run from the repository root (where R/snippets/ lives).")

NMDIR <- "nm"

#  The run folder (nm/<model>.R76/) is **left in place**, because nmw's
#  post-processing presumes that structure: the model name comes from the
#  first token of the folder name (GetCurModelName), the tables must be
#  sdtab/patab/cotab/catab with no numbers (CTL_Style_Guide 15), and the
#  eight reports read .xml, .phi, .grd, PRINT.OUT and FDATA.CSV. Anything not in the list below is an intermediate and is deleted (nonmem.exe is 30 MB).
KEEP <- function(model) c(
  paste0(model, c(".ctl", ".lst", ".ext", ".xml", ".phi", ".grd",
                  ".cov", ".cor", ".coi")),
  "sdtab", "patab", "cotab", "catab",     # the four nmw-compatible tables
  "simtab.csv",                           # simulation table of a $SIM-only run (Ch 12)
  "FCON",                                 # SumOut reads P:/F: from here
  "PRINT.OUT",                            # produced by TrimOut (Ch 2)
  "FDATA.csv",                            # the data copy NONMEM writes
  "nmfe.log")

# ---- Find nmfe. Without it we stop here ------------------------------
find_nmfe <- function() {
  cand <- c("C:/nm76g64/run/nmfe76.bat", "C:/nm75g64/run/nmfe75.bat",
            Sys.getenv("NMFE", ""))
  cand <- cand[nzchar(cand) & file.exists(cand)]
  if (!length(cand)) return(NA_character_)
  cand[1]
}

NMFE <- find_nmfe()
if (is.na(NMFE)) {
  message("NONMEM not found. It cannot be run on this machine.\n",
          "  The run artifacts are committed under nm/, so Rscript R/build.R\n",
          "  still runs. If a control stream changed, run this where licensed.")
  quit(save = "no", status = 0)     # not a failure; there is simply nothing to do
}
message("nmfe: ", NMFE)

# ---- Scrub the licensee string ---------------------------------------
#  NONMEM stamps the licensee and the expiry date at the head of its output.
#  This may go out as a public repository (PUBLIC.md), so it is scrubbed
#  **where it is produced**, so that it never enters the git history.
scrub <- function(f) {
  if (!file.exists(f)) return(invisible())
  x <- readLines(f, warn = FALSE)
  x <- sub("(?i)^(\\s*License(d| Registered)? ?(to)?:).*$", "\\1 <LICENSEE>",
           x, perl = TRUE)
  x <- sub("(?i)^(\\s*Expiration Date:).*$",  "\\1 <DATE>", x, perl = TRUE)
  x <- sub("(?i)^(\\s*Current Date:).*$",     "\\1 <DATE>", x, perl = TRUE)
  x <- sub("(?i)^(\\s*Days until program expires).*$", "\\1 : <N>", x, perl = TRUE)

  # The run time and elapsed seconds differ on every run. The estimation
  # result does not change by one bit, yet the file does, so left alone the
  # diff under nm/ stops working as a signal. Scrubbed, **a diff means
  # something really changed.** (Same reason R/_freeze.R scrubs nlr()'s $`Elapsed Time`.)
  x <- sub("^\\d{4}-\\d{2}-\\d{2}\\s*$", "<DATE>", x)
  x <- sub("^\\d{2}:\\d{2}\\s*$",        "<TIME>", x)
  x <- sub("^(\\s*Elapsed \\w+\\s+time in seconds:).*$", "\\1 <SEC>", x, perl = TRUE)
  x <- sub("^(\\s*#CPUT: Total CPU Time in Seconds,).*$", "\\1 <SEC>", x, perl = TRUE)
  writeLines(x, f)
}

# ---- Run one model ---------------------------------------------------
run_one <- function(model) {
  stopifnot(file.exists(file.path(NMDIR, paste0(model, ".ctl"))))
  nmfe <- normalizePath(NMFE)

  # NONMEM runs in a working folder under nm/ (Analects 3). So the $DATA of
  # the control stream points two levels up from there: ../../data/...
  owd <- setwd(NMDIR); on.exit(setwd(owd), add = TRUE)
  # nmfe moves into the working folder and looks for the control stream
  # there ("Make sure directory exists with all necessary input files"), so copy it in first.
  rundir <- paste0(model, ".R76")
  unlink(rundir, recursive = TRUE)
  dir.create(rundir)
  file.copy(paste0(model, ".ctl"), rundir)

  # nmfe creates gfcompile.bat in the working folder and does
  # `call gfcompile.bat`. Where NoDefaultCurrentDirectoryInExePath is set,
  # cmd does not look for a batch file in the current folder and halts with
  # "is not recognized" (some security policies and some shells set it).
  # Inside a batch file one would write `call .\gfcompile.bat`, but we do not modify nmfe (nm/README.md), so we clear the variable from outside.
  Sys.unsetenv("NoDefaultCurrentDirectoryInExePath")

  message("\n== ", model, " ", strrep("-", 50))
  t0 <- Sys.time()
  st <- system2(nmfe, c(paste0(model, ".ctl"), paste0(model, ".lst"),
                        paste0("-rundir=", rundir)),
                stdout = TRUE, stderr = TRUE)
  # Wall-clock time. scrub() removes the elapsed time from the .lst (for the
  # sake of diff), so it is kept here. Ch 8 reads this line when comparing the cost of estimation methods.
  wall <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
  writeLines(c(st, sprintf("wall seconds: %.1f", wall)), file.path(rundir, "nmfe.log"))

  # ---- Create the entrance to post-processing (Ch 2) -------------------
  #  PRINT.OUT is the output with the control characters trimmed. nmw's
  #  termination test looks for this **name**, so it is created inside the  run folder. FDATA.csv is written by NONMEM itself.
  lst <- file.path(rundir, paste0(model, ".lst"))
  if (file.exists(lst) && requireNamespace("nmw", quietly = TRUE))
    try(nmw::TrimOut(lst, file.path(rundir, "PRINT.OUT")), silent = TRUE)

  # ---- Tidy the simulation table (Ch 12) -------------------------------
  #  NONMEM writes a fresh header per replicate and records every dose too,
  #  so the file reaches 8 MB. The VPC uses only the **observation records**,
  #  so keep those alone and convert to a CSV carrying a REP number
  #  (it falls below 1 MB). This must be done **before** the intermediates  are deleted. The original simtab is not kept.
  ctl <- readLines(paste0(model, ".ctl"), warn = FALSE)
  simonly <- any(grepl("^[$]SIM", ctl)) && !any(grepl("^[$]EST", ctl))
  raw <- file.path(rundir, "simtab")
  if (simonly && file.exists(raw)) {
    x   <- readLines(raw, warn = FALSE)
    hdr <- grepl("^TABLE NO", x)
    col <- grepl("^ +ID", x)
    nms <- strsplit(trimws(x[which(col)[1]]), "[ ]+")[[1]]     # column names from the table header
    d   <- read.table(text = x[!hdr & !col], col.names = nms)
    d$REP <- rep(seq_len(sum(hdr)), each = nrow(d) / sum(hdr))
    d <- d[d$MDV == 0, c("REP", setdiff(nms, "MDV"))]
    write.csv(d, file.path(rundir, "simtab.csv"), row.names = FALSE, quote = FALSE)
    message(sprintf("  SIMULATION x%d, %d observation rows", sum(hdr), nrow(d)))
  }

  # ---- Delete intermediates and tidy what remains ----------------------
  #  Windows does not distinguish case in file names. NONMEM writes
  #  FDATA.csv in lower case while nmw looks for FDATA.CSV, so the  comparison ignores case too.
  keep <- toupper(KEEP(model))
  have <- list.files(rundir)
  for (f in have[!toupper(have) %in% keep])
    unlink(file.path(rundir, f), recursive = TRUE)
  for (f in have[toupper(have) %in% keep]) scrub(file.path(rundir, f))
  unlink("trash.tmp")

  if (simonly) {
    ok <- file.exists(file.path(rundir, "simtab.csv"))
    if (!ok) message("  ** no simulation table. Look at the .lst")
  } else {
    #  The gradient family ends with MINIMIZATION SUCCESSFUL; the EM family and BAYES end with other wording.
    ok <- file.exists(lst) &&
          any(grepl("MINIMIZATION SUCCESSFUL|WAS NOT TESTED FOR CONVERGENCE|WAS COMPLETED",
                    readLines(lst, warn = FALSE)))
    message(if (ok) "  MINIMIZATION SUCCESSFUL" else "  ** did not converge. Look at the .lst")
  }
  invisible(ok)
}

models <- commandArgs(trailingOnly = TRUE)
if (!length(models)) {
  models <- sub("\\.ctl$", "", basename(list.files(NMDIR, "\\.ctl$")))
  # Two things are left out when running everything with no name given.
  #   rpt, boot : they run on temporary data only (R/rpt.R, R/boot.R)
  #   leading _ : they are produced by a script (R/llp.R)
  models <- setdiff(models, c("rpt", "boot"))
  models <- models[!startsWith(models, "_")]
}

for (m in models) run_one(m)
message("\ndone.  next: Rscript R/build.R")
