# =====================================================================
#  R/llp.R  -  log-likelihood profile (Ch 14).  Licensed machines only.
#  Run from the repository root:   Rscript R/llp.R
#
#  Fix one parameter at a value on a grid and **re-estimate all the rest**.
#  The OFV curve so obtained is the profile likelihood. Where dOFV reaches
#  3.84 is the end of the 95 % confidence interval (1 degree of freedom).
#
#  The result comes down to one file, nm/llp/llp.csv.
# =====================================================================
if (!dir.exists("R/snippets")) stop("Run from the repository root.")

e   <- read.table("nm/108wt.R76/108wt.ext", skip = 1, header = TRUE)
fin <- e[e$ITERATION == -1000000000, ]
se  <- e[e$ITERATION == -1000000001, ]

#  The grid is laid out using the asymptotic standard error as its ruler. If
#  the normal approximation holds, dOFV = 3.84 falls at +-1.96 SE. Since the point is to see whether it does, we look out to +-3 SE.
#
#  A bounded parameter cannot cross its bound. A grid point that would is
#  pulled back to just inside the bound. If dOFV still falls short of 3.84
#  there, the 95 % interval has no end in that direction (the bound lies inside the interval).
STEP <- seq(-3, 3, by = 0.5)
PARS <- c("T3", "T5", "T6")
LO   <- c(T3 = 0, T5 = -20, T6 = -20)     # lower bounds as written in the control stream
grid <- do.call(rbind, lapply(PARS, function(p) {
  k <- paste0("THETA", substr(p, 2, 2))
  v <- pmax(fin[[k]] + STEP * se[[k]], LO[[p]] + 0.01 * se[[k]])
  data.frame(PAR = p, VALUE = sort(unique(v)))
}))
stopifnot(grid$VALUE[grid$PAR == "T3"] > 0)

tpl <- readLines("nm/llp.ctl", warn = FALSE)
dir.create("nm/llp", showWarnings = FALSE)

grid$OFV  <- NA_real_
grid$TERM <- NA_character_
t0 <- Sys.time()
for (i in seq_len(nrow(grid))) {
  #  Replace only the marked line with "<value> FIX". Nothing else is touched.
  mark <- paste0("<", grid$PAR[i], ">")
  j <- grep(mark, tpl, fixed = TRUE)
  stopifnot(length(j) == 1)
  x <- tpl
  x[j] <- sprintf("  %.8g FIX  ; %s", grid$VALUE[i], mark)
  writeLines(x, "nm/_llp.ctl")

  suppressWarnings(system2("Rscript", c("R/runnm.R", "_llp"),
                           stdout = NULL, stderr = NULL))

  f <- "nm/_llp.R76/_llp.ext"
  if (file.exists(f)) {
    z <- read.table(f, skip = 1, header = TRUE)
    grid$OFV[i] <- z[z$ITERATION == -1000000000, "OBJ"]
  }
  l <- "nm/_llp.R76/_llp.lst"
  grid$TERM[i] <- if (!file.exists(l)) "NO OUTPUT" else {
    y <- readLines(l, warn = FALSE)
    if (any(grepl("MINIMIZATION SUCCESSFUL", y)))      "SUCCESS"
    else if (any(grepl("ROUNDING ERRORS", y)))         "ROUNDING"
    else if (any(grepl("MINIMIZATION TERMINATED", y))) "TERMINATED"
    else                                               "OTHER"
  }
  message(sprintf("  %2d/%d  %s = %.4g  OFV = %.2f  %s", i, nrow(grid),
                  grid$PAR[i], grid$VALUE[i], grid$OFV[i], grid$TERM[i]))
}

#  A profile OFV **cannot be smaller** than the overall minimum. It was
#  optimized with one parameter tied down, so it is at least that much
#  worse. If it came out smaller, that run is broken (the objective function
#  was not computed on the same data). This is an inequality, not an assumption, so it serves directly as a check.
#  The grid point sitting exactly at the optimum comes out about 1e-6 low
#  from numerical error. That much is allowed; only larger shortfalls count as broken.
bad <- which(!is.na(grid$OFV) & grid$OFV < fin$OBJ - 0.01)
if (length(bad)) {
  message("\n** ", length(bad), " point(s) below the overall minimum. Broken run.")
  print(grid[bad, c("PAR", "VALUE", "OFV", "TERM")])
}

write.csv(grid, "nm/llp/llp.csv", row.names = FALSE, quote = FALSE)
unlink(c("nm/_llp.ctl", "nm/_llp.R76"), recursive = TRUE)
message(sprintf("\n%d points, total %s", nrow(grid), format(round(Sys.time() - t0))))
message("written to nm/llp/llp.csv.  next: Rscript R/build.R")
