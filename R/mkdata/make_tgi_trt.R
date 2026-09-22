# =====================================================================
#  R/mkdata/make_tgi_trt.R  -  the treatment-effect practice data of Ch 19
#  Run from the repository root:   Rscript R/mkdata/make_tgi_trt.R
#
#  The Benzekry data has control animals only. Practicing with a treatment
#  effect needs a treated arm whose truth is known. Taking the estimates of
#  tg102b (Gompertz, block) as the truth, 20 control and 20 treated animals
#  are generated. Treatment starts on day 7 after implantation and lowers the  growth rate ALPHA by 40 % (truth THETA(5) = -0.4). The sampling design is the same as the original.
#  Result: data/tgi-trt.csv (ID TIME DV MDV GRP), GRP 0 control, 1 treated.
# =====================================================================
if (!file.exists("PMx.tex")) stop("Run from the repository root.")
set.seed(20260917)
RNGkind()

e  <- read.table("nm/tg102b.R76/tg102b.ext", skip = 1, header = TRUE)
f  <- unlist(e[e$ITERATION == -1000000000, -1])
th <- f[paste0("THETA", 1:4)]
Om <- matrix(f[c("OMEGA.1.1.", "OMEGA.2.1.", "OMEGA.2.1.", "OMEGA.2.2.")], 2)
EFF   <- -0.4                      # ALPHA multiplier of the treated arm, minus 1
TSTART <- 7                        # day treatment starts
times <- c(7, 9, 11, 13, 15, 17, 19, 21)

gomp <- function(t, a, b) exp(a / b * (1 - exp(-b * t)))     # V0 = 1
rows <- list()
for (grp in 0:1) for (k in 1:20) {
  id  <- grp * 20 + k
  eta <- MASS::mvrnorm(1, c(0, 0), Om)
  a   <- th[1] * exp(eta[1]); b <- th[2] * exp(eta[2])
  # Before treatment the curve is the control's. After it starts the growth
  # rate is (1+EFF) times. There is no closed form, so it is joined
  # piecewise, taking the volume at the start as the new initial value.
  v <- sapply(times, function(t) {
    if (grp == 0 || t <= TSTART) return(gomp(t, a, b))
    v7 <- gomp(TSTART, a, b)
    # The Gompertz growth rate decays as alpha*exp(-beta*t). Treatment lowers
    # alpha only.
    v7 * exp(a * (1 + EFF) / b * (exp(-b * TSTART) - exp(-b * t)))
  })
  w  <- sqrt(th[3]^2 + th[4]^2 * v^2)
  y  <- pmax(v + w * rnorm(length(v)), 1)
  rows[[length(rows) + 1]] <- data.frame(ID = id, TIME = times, DV = round(y, 1),
                                         MDV = 0L, GRP = grp)
}
d <- do.call(rbind, rows)
write.csv(d, "data/tgi-trt.csv", row.names = FALSE, quote = FALSE)
cat(sprintf("data/tgi-trt.csv: %d rows, %d control, %d treated, true EFF = %.2f\n",
            nrow(d), sum(d$GRP == 0), sum(d$GRP == 1), EFF))
