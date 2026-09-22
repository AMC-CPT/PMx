# The SIR results (R/sir.R). 400 vectors were drawn from the proposal
# distribution, only the objective function was computed for each, and 200 were
# resampled according to the weights. Nothing was ever estimated.
s <- read.csv("nm/sir/sir.csv")
c(evaluations = nrow(s), ESS = round(1 / sum(s$W^2), 1),
  max.weight = round(max(s$W), 3), vectors.drawn = sum(s$PICK > 0))

# Percentiles of the resampled ones. PICK is how many times that vector was drawn.
sirq <- t(sapply(c("T3", "T5", "T6"), function(k)
  quantile(rep(s[[k]], s$PICK), c(0.025, 0.975))))
round(sirq, 4)
