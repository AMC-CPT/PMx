# =====================================================================
#  R/sir.R  -  SIR, sampling importance resampling (Ch 14).
#  Run from the repository root:   Rscript R/sir.R [proposal draws]
#
#  Take the asymptotic covariance matrix as the proposal, draw M parameter
#  vectors, and at each **compute the objective function only** (MAXEVAL=0;
#  nothing is estimated, so there is no convergence failure). Resample m of them with the ratio of likelihood to proposal density as the weight.
#
#  It differs from bootstrap in two ways.
#    - it needs a proposal, so $COV must have succeeded
#    - what it yields is closer to a posterior than to a confidence interval
#
#  The result comes down to one file, nm/sir/sir.csv.
# =====================================================================
if (!dir.exists("R/snippets")) stop("Run from the repository root.")
M <- as.integer(c(commandArgs(trailingOnly = TRUE), "400")[1])
RESAMPLE <- 200
INFLATE  <- 2          # inflate the proposal; if it misses the tail the weights blow up

e   <- read.table("nm/108wt.R76/108wt.ext", skip = 1, header = TRUE)
fin <- unlist(e[e$ITERATION == -1000000000, -1])

#  Read the $COV matrix. SIGMA is fixed, so its row and column are zero and are dropped.
cv  <- read.table("nm/108wt.R76/108wt.cov", skip = 1, header = TRUE,
                  check.names = FALSE)
rownames(cv) <- cv$NAME; cv$NAME <- NULL
keep <- setdiff(rownames(cv), "SIGMA(1,1)")
S <- as.matrix(cv[keep, keep]) * INFLATE
mu <- fin[c("THETA1", "THETA2", "THETA3", "THETA4", "THETA5", "THETA6",
            "OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.2.")]
names(mu) <- keep
stopifnot(all(eigen(S, only.values = TRUE)$values > 0))   # is the proposal usable?

#  Draw from a multivariate normal. One Cholesky is enough (no package needed).
L <- chol(S)
draw1 <- function() as.vector(mu + t(L) %*% rnorm(length(mu)))

#  Does the draw make sense in the model? If not, discard and draw again.
#  Count the discards too: many of them means the proposal sits in the wrong place.
ok_draw <- function(v) {
  all(v[1:4] > 0) &&                                  # CL, V, residual error > 0
  v[7] > 0 && v[9] > 0 &&                             # OMEGA diagonal > 0
  (v[7] * v[9] - v[8]^2) > 0                          # the 2x2 block is positive definite
}

#  The proposal density. The constant cancels in the weight, so the quadratic form alone suffices.
Si <- solve(S)
logg <- function(v) { z <- v - mu; -0.5 * as.numeric(t(z) %*% Si %*% z) }

tpl <- readLines("nm/sir.ctl", warn = FALSE)
jT  <- grep("<THETA>", tpl, fixed = TRUE)
jO  <- grep("<OMEGA>", tpl, fixed = TRUE)
stopifnot(length(jT) == 1, length(jO) == 1)

write_ctl <- function(v) {
  x <- c(tpl[seq_len(jT - 1)],
         sprintf("  %.8g FIX", v[1:6]),
         tpl[(jT + 1):(jO - 1)],
         sprintf("  %.8g", v[7]),
         sprintf("  %.8g  %.8g", v[8], v[9]),
         tpl[(jO + 1):length(tpl)])
  writeLines(x, "nm/_sir.ctl")
}

dir.create("nm/sir", showWarnings = FALSE)
set.seed(20260917)
RNGkind()

res <- as.data.frame(matrix(NA_real_, M, length(mu)))
names(res) <- c(paste0("T", 1:6), "O11", "O21", "O22")
res$OFV  <- NA_real_
res$LOGG <- NA_real_
nrej <- 0
t0 <- Sys.time()
for (i in seq_len(M)) {
  for (try in 1:1000) { v <- draw1(); if (ok_draw(v)) break; nrej <- nrej + 1 }
  if (!ok_draw(v)) stop("The proposal sits in the wrong place: 1000 draws, all discarded.")
  write_ctl(v)
  suppressWarnings(system2("Rscript", c("R/runnm.R", "_sir"),
                           stdout = NULL, stderr = NULL))
  f <- "nm/_sir.R76/_sir.ext"
  if (file.exists(f)) {
    z <- read.table(f, skip = 1, header = TRUE)
    res$OFV[i] <- z[z$ITERATION == -1000000000, "OBJ"]
  }
  res[i, 1:length(mu)] <- v
  res$LOGG[i] <- logg(v)
  if (i %% 25 == 0)
    message(sprintf("  %3d/%d  discarded %d  elapsed %s", i, M, nrej,
                    format(round(Sys.time() - t0))))
}

#  The weights. log w = -OFV/2 - log g. Subtract the maximum before exponentiating (to avoid overflow).
lw <- -res$OFV / 2 - res$LOGG
lw[is.na(lw)] <- -Inf
w  <- exp(lw - max(lw, na.rm = TRUE)); w <- w / sum(w)
res$W <- w

#  Diagnostic. A small effective sample size means a few draws took all the weight.
ess <- 1 / sum(w^2)
message(sprintf("\nESS = %.1f / %d   max weight = %.3f   discarded %d",
                ess, M, max(w), nrej))

res$PICK <- 0L
pick <- sample(seq_len(M), RESAMPLE, replace = TRUE, prob = w)
tb <- table(pick)
res$PICK[as.integer(names(tb))] <- as.integer(tb)

write.csv(res, "nm/sir/sir.csv", row.names = FALSE, quote = FALSE)
unlink(c("nm/_sir.ctl", "nm/_sir.R76"), recursive = TRUE)
message(sprintf("%d evaluations, total %s", M, format(round(Sys.time() - t0))))
message("written to nm/sir/sir.csv.  next: Rscript R/build.R")
