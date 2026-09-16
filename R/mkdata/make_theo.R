# =====================================================================
#  R/mkdata/make_theo.R  -  7장의 경구 흡수 예제 데이터셋을 만든다
#  저장소 최상위에서 실행:   Rscript R/mkdata/make_theo.R
#
#  원 자료는 NONMEM 배포본 util/THEO 의 사본 data/theo-raw.txt 다(6장).
#  12명, theophylline 경구 단회 투여, 대상자당 농도 11개. 열은
#  ID DOSE TIME CP WT 이고 DOSE 는 mg/kg 다. 실제 투여량은 DOSE*WT mg.
#
#  6장이 찾은 9번의 용량 오기(3.10, 옳은 값은 3.70)는 **고치지 않는다.**
#  자료는 있는 그대로 두고, 고친 값으로 돌린 민감도분석은 연습문제로 둔다.
#
#  결과: data/theo-nm.csv (ID TIME AMT RATE DV MDV EVID WT)
#    RATE = -2 는 0차 흡수 모형(112zo)이 흡수 시간 D1 을 추정할 때 쓴다.
#    1차 흡수 모형은 $INPUT 에서 RATE=DROP 으로 버린다.
# =====================================================================
if (!file.exists("PMx.tex")) stop("저장소 최상위에서 실행하라.")

raw <- read.table("data/theo-raw.txt", header = FALSE,
                  col.names = c("ID", "DOSE", "TIME", "CP", "WT"))
# 원자료는 첫 행(시각 0)에만 용량이 적혀 있고 나머지는 '.' 이다.
for (v in c("DOSE", "CP", "WT")) raw[[v]] <- suppressWarnings(as.numeric(raw[[v]]))
out <- list()
for (i in unique(raw$ID)) {
  z <- raw[raw$ID == i, ]
  amt <- z$DOSE[1] * z$WT[1]                       # mg/kg -> mg
  out[[length(out) + 1]] <- data.frame(ID = i, TIME = 0, AMT = round(amt, 2), RATE = -2,
                                       DV = NA, MDV = 1L, EVID = 1L, WT = z$WT[1])
  # 시각 0 의 농도가 0 이 아니다(식이 등의 theophylline). 투여 전 관측이므로
  # 적합에서는 빼되(MDV=1) 레코드는 남긴다(5장의 규칙).
  obs <- z[!is.na(z$CP), ]
  out[[length(out) + 1]] <- data.frame(ID = i, TIME = obs$TIME, AMT = 0, RATE = 0,
                                       DV = obs$CP, MDV = as.integer(obs$TIME <= 0),
                                       EVID = 0L, WT = z$WT[1])
}
d <- do.call(rbind, out)
d <- d[order(d$ID, d$TIME, -d$EVID), ]
rownames(d) <- NULL
write.csv(d, "data/theo-nm.csv", row.names = FALSE, quote = FALSE, na = ".")
cat(sprintf("data/theo-nm.csv: %d 행, %d 명, 관측 %d, 용량 %s mg\n", nrow(d),
            length(unique(d$ID)), sum(d$MDV == 0),
            paste(range(d$AMT[d$EVID == 1]), collapse = "-")))
