# The simplest form of a clinical trial simulation. With the pharmacodynamic
# model of Ch 17 (true values), run the trial 500 times and see how often the
# NRS at 4 hours is judged different between placebo and the 80 mg arm.
tr <- read.csv("data/pd-sim-truth.csv"); p <- setNames(tr$value, tr$name)
one_trial <- function(n, dose = 80, t = 4) {
  eta  <- sapply(c("OM_CL", "OM_V", "OM_LB", "OM_PLMAX", "OM_EC50"),
                 function(v) rnorm(2 * n, 0, sqrt(p[v])))
  d    <- rep(c(0, dose), each = n)
  conc <- d / (p["V"] * exp(eta[, 2])) * exp(-p["CL"] / p["V"] * exp(eta[, 1] - eta[, 2]) * t)
  L    <- p["LB"] + eta[, 3] - p["PLMAX"] * exp(eta[, 4]) * (1 - exp(-p["KPL"] * t)) -
          p["EMAX"] * conc / (p["EC50"] * exp(eta[, 5]) + conc)
  f    <- 10 / (1 + exp(-L))                        # the logit link of Ch 17
  y    <- f + sqrt(p["A"]^2 + p["B"]^2 * f * (10 - f)) * rnorm(2 * n)
  t.test(y[d == 0], y[d > 0])$p.value < 0.05
}
set.seed(20260917)
power <- sapply(c(5, 10, 15, 20, 30), function(n) mean(replicate(500, one_trial(n))))
round(setNames(power, paste0("n=", c(5, 10, 15, 20, 30))), 2)
