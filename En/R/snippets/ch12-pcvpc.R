# pcVPC. When dose and weight differ from person to person inside the same bin,
# so do the predictions, and that difference shows up as scatter in the
# observations and blunts the VPC. Correct by the prediction.
#   pcDV = DV * (median PRED of the bin) / PRED of that record    (Bergstrand 2011)
pr <- obs[, c("ID", "TIME", "PRED")]
sim2 <- merge(sim, pr, by = c("ID", "TIME"))
stopifnot(nrow(sim2) == nrow(sim))          # did the merge leave the rows alone?

mpred <- tapply(obs$PRED, obs$BIN, median)
obs$PCDV  <- obs$DV  * mpred[obs$BIN]  / obs$PRED
sim2$PCDV <- sim2$DV * mpred[sim2$BIN] / sim2$PRED

oq2 <- sapply(qs, function(q) tapply(obs$PCDV, obs$BIN, quantile, q))
sq2 <- sapply(qs, function(q) {
  m <- tapply(seq_len(nrow(sim2)), list(sim2$BIN, sim2$REP),
              function(i) quantile(sim2$PCDV[i], q))
  t(apply(m, 1, quantile, c(0.025, 0.5, 0.975), na.rm = TRUE))
}, simplify = "array")

# Put the observed quantiles before and after the correction side by side.
round(cbind(before = oq[, 3], after = oq2[, 3]), 1)
