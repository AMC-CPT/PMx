# pcVPC. 같은 구간 안에서도 사람마다 용량과 체중이 달라 예측이 다르면,
# 그 차이가 관측의 흩어짐으로 보여 VPC 가 무뎌진다. 예측값으로 보정한다.
#   pcDV = DV * (구간의 중앙 PRED) / 그 레코드의 PRED      (Bergstrand 2011)
pr <- obs[, c("ID", "TIME", "PRED")]
sim2 <- merge(sim, pr, by = c("ID", "TIME"))
stopifnot(nrow(sim2) == nrow(sim))          # merge 가 행을 바꾸지 않았는가

mpred <- tapply(obs$PRED, obs$BIN, median)
obs$PCDV  <- obs$DV  * mpred[obs$BIN]  / obs$PRED
sim2$PCDV <- sim2$DV * mpred[sim2$BIN] / sim2$PRED

oq2 <- sapply(qs, function(q) tapply(obs$PCDV, obs$BIN, quantile, q))
sq2 <- sapply(qs, function(q) {
  m <- tapply(seq_len(nrow(sim2)), list(sim2$BIN, sim2$REP),
              function(i) quantile(sim2$PCDV[i], q))
  t(apply(m, 1, quantile, c(0.025, 0.5, 0.975), na.rm = TRUE))
}, simplify = "array")

# 보정 전후의 관측 분위수를 나란히 본다.
round(cbind(보정전 = oq[, 3], 보정후 = oq2[, 3]), 1)
