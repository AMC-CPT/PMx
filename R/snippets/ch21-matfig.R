# 성숙 함수의 모양. 참값 TM50 55주, Hill 3.4. 신생아(PMA 28-44주)는 곡선의
# 가파른 앞부분에 있고, 2세(PMA 약 144주)면 거의 다 올라와 있다.
mat <- function(pma, tm50 = 55, hill = 3.4) pma^hill / (tm50^hill + pma^hill)
pma <- seq(24, 200, length.out = 300)
par(mfrow = c(1, 2), mar = c(4, 4, 1.5, 1))
plot(pma, mat(pma), type = "l", lwd = 2, col = "#123669", xlab = "PMA (주)",
     ylab = "성숙 분율", main = "MAT(PMA)")
abline(v = 40, lty = 3); abline(h = 0.5, lty = 3)
rug(s$PMA[s$PMA < 200], col = "#B2182B")
# 크기를 걷어 낸 청소율. CL / (WT/70)^0.75 을 PMA 에 대해. 참값의 성숙 곡선이 보인다.
pa <- read.table("nm/ped101.R76/patab", skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
cls <- pa$CL / (s$WT / 70)^0.75
plot(s$PMA, cls, log = "x", pch = 16, col = c("#B2182B", "#4DAF4A", "#123669", "grey40")[s$GRP],
     xlab = "PMA (주, 로그 축)", ylab = "CL / (WT/70)^0.75 (L/h)", main = "크기를 걷어 낸 청소율")
lines(pma <- seq(24, 1000, length.out = 300), 6 * mat(pma), lwd = 2)
legend("bottomright", grp, pch = 16, col = c("#B2182B", "#4DAF4A", "#123669", "grey40"),
       bty = "n", cex = 0.8)
