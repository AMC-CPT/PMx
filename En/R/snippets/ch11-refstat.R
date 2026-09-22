# The impression of the figure as a number: the slope of DV regressed on PRED
# in the observed data, and the distribution of that same slope over 200
# simulations. If the observed slope lies inside the simulated distribution,
# the shape is one the model being right can produce. That the slope is not 1
# means nothing in itself.
slope <- function(d) unname(coef(lm(DV ~ PRED, d))[2])
s_obs <- slope(obs)
pr    <- obs[, c("ID", "TIME", "PRED")]
s_sim <- sapply(split(sim, sim$REP), function(z) slope(merge(z, pr, by = c("ID", "TIME"))))
c(observed = round(s_obs, 3), sim.median = round(median(s_sim), 3),
  sim.5 = round(unname(quantile(s_sim, 0.05)), 3),
  sim.95 = round(unname(quantile(s_sim, 0.95)), 3),
  position.of.observed = round(mean(s_sim < s_obs), 2))
