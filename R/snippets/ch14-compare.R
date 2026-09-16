# 넷을 나란히 놓는다. 점근 근사, 재표집, 프로파일 가능도, SIR.
span <- function(k) {
  m <- fin[[key[[k]]]]; s2 <- se[[key[[k]]]]
  x <- rbind(점근     = m + c(-1.96, 1.96) * s2,
             재표집   = unname(quantile(b[[k]], c(0.025, 0.975), na.rm = TRUE)),
             프로파일 = llp[k, ],
             SIR      = sirq[k, ])
  colnames(x) <- c("하한", "상한")
  cbind(x, 폭 = x[, 2] - x[, 1])
}
for (k in c("T3", "T5", "T6")) {
  cat("\n", k, "   추정 ", signif(fin[[key[[k]]]], 4), "\n", sep = "")
  print(round(span(k), 4))
}
