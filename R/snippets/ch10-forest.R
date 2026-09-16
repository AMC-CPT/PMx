# 공변량 효과의 forest plot. 체중의 5, 25, 75, 95 백분위수에서 청소율이
# 참조값(1.5 kg)의 몇 배인지를, 점근 SE 로 구간을 붙여 그린다. 보고서와 검토자가
# 실제로 읽는 것은 지수가 아니라 이 배수다(19장의 셋째 질문).
wt  <- quantile(d$WT[!duplicated(d$ID)], c(0.05, 0.25, 0.75, 0.95))
b   <- est[["THETA5"]]; sb <- se[["THETA5"]]
ratio <- function(w, bb) (w / 1.5)^bb
lo <- ratio(wt, b - 1.96 * sb); hi <- ratio(wt, b + 1.96 * sb)   # 참조보다 가벼우면 뒤집힌다
tab <- data.frame(체중 = round(wt, 2), 비 = round(ratio(wt, b), 2),
                  하한 = round(pmin(lo, hi), 2), 상한 = round(pmax(lo, hi), 2))
tab
par(mar = c(4, 6, 1, 1))
plot(tab$비, seq_along(wt), xlim = c(0.2, 3), log = "x", yaxt = "n", pch = 16,
     col = "#123669", xlab = "CL 비 (참조 1.5 kg = 1)", ylab = "")
segments(tab$하한, seq_along(wt), tab$상한, seq_along(wt), lwd = 2, col = "#123669")
axis(2, seq_along(wt), paste0(round(wt, 2), " kg"), las = 1)
abline(v = 1, lty = 2); rect(0.8, 0, 1.25, 5, col = "#12366911", border = NA)   # 0.8-1.25
