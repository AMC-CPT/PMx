# 청소율 ETA 를 PMA 에 대해. 성숙을 뺀 모형(왼쪽)에서는 신생아의 ETA 가 한 방향으로
# 몰린다. 모형이 설명하지 못한 것이 임의효과에 남은 것이다. 성숙을 넣으면(오른쪽) 사라진다.
eta <- function(m) { p <- read.table(nmf(m, "patab"), skip = 1, header = TRUE); p[!duplicated(p$ID), "ETA1"] }
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
for (z in list(list("ped100", "크기만"), list("ped101", "크기 + 성숙"))) {
  e <- eta(z[[1]])
  plot(s$PMA, e, log = "x", pch = 16, col = c("#B2182B", "#4DAF4A", "#123669", "grey40")[s$GRP],
       xlab = "PMA (주, 로그 축)", ylab = "ETA(CL)", main = z[[2]], ylim = c(-2.5, 1))
  lines(lowess(log(s$PMA), e, f = 0.5)$x |> exp(), lowess(log(s$PMA), e, f = 0.5)$y,
        col = "grey30", lwd = 2)
  abline(h = 0, lty = 3)
}
