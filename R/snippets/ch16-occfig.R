# 네 명의 세 회차. 같은 사람인데 회차마다 곡선이 다르다. 그 차이가 IOV 다.
# 3번은 아집단(청소율 30 %)이라 농도가 높고 늦게 떨어진다.
ids <- c(1, 3, 5, 9)
par(mfrow = c(1, 4), mar = c(4, 3.5, 2, 0.5), oma = c(0, 1, 0, 0))
for (i in ids) {
  o <- obs[obs$ID == i, ]
  plot(NA, xlim = c(0, 24), ylim = c(0, 5.5), xlab = "투여 후 시간 (h)", ylab = "",
       main = paste0("ID ", i, if (o$POP[1] == 2) " (저하)" else ""))
  for (k in 1:3) {
    z <- o[o$OCC == k, ]
    lines(z$TIME - c(0, 168, 336)[k], z$DV, type = "b", pch = c(16, 1, 17)[k],
          col = c("#123669", "#B2182B", "#4DAF4A")[k], cex = 0.8)
  }
  if (i == ids[1]) legend("topright", paste0("회차 ", 1:3), pch = c(16, 1, 17),
                          col = c("#123669", "#B2182B", "#4DAF4A"), bty = "n", cex = 0.85)
}
mtext("농도 (mg/L)", side = 2, outer = TRUE, line = -0.5)
