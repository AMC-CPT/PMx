# 정답과 대조한다. 이 실습 자료는 pheno.csv 를 분해해 만든 것이므로 정답을 안다.
ans <- read.csv("data/pheno.csv", na.strings = ".")

pre <- NMDS$EVID == 0 & NMDS$MDV == 1    # 투여 전 채혈. 정답에는 없다
out <- NMDS[!pre, ]
c(정답 = nrow(ans), 조립 = nrow(out), 투여전 = sum(pre))

stopifnot(
  nrow(out) == nrow(ans),
  all(out$ID == ans$ID), all(out$EVID == ans$EVID), all(out$APGR == ans$APGR),
  max(abs(out$TAFD - ans$TIME))                             < 1e-6,
  max(abs(out$WT   - ans$WT))                               < 1e-9,
  max(abs(out$AMT[out$EVID == 1] - ans$AMT[ans$EVID == 1])) < 1e-9,
  max(abs(out$DV[out$MDV == 0]   - ans$DV[ans$MDV == 0]))   < 1e-9
)
"조립한 744 행이 모두 정답과 일치한다"

# 계획시각으로 조립했다면 시간축이 얼마나 틀어졌겠는가.
err <- as.numeric(difftime(parse_dtc(PC$PCDTC), parse_dtc(PC$PCDTC_ACTUAL),
                           units = "mins"))[PC$PCREASND != "PREDOSE"]
c(어긋난관측 = sum(err != 0), 최대분 = max(abs(err)),
  평균절대분 = round(mean(abs(err)), 1))

# 검증을 통과한 것만 내보낸다. 이것이 6장의 입력이다.
# quote = FALSE 로 쓴다. 따옴표가 붙으면 NM-TRAN 이 읽지 못한다.
write.csv(NMDS, "data/pheno-nm.csv", row.names = FALSE, quote = FALSE)
