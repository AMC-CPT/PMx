# PC 에 적힌 시각은 계획시각이다. 실제로 언제 뽑았는지는 다른 도메인에 있다.
PC$SUBJID <- PC$USUBJID
n0 <- nrow(PC)
PC <- merge(PC, CO[, c("USUBJID", "PCDTC_PLANNED", "PCDTC_ACTUAL")],
            by.x = c("USUBJID", "PCDTC"), by.y = c("USUBJID", "PCDTC_PLANNED"))
# merge 가 행을 늘리지도 줄이지도 않았는지 그 자리에서 확인한다
stopifnot(nrow(PC) == n0, !anyNA(PC$PCDTC_ACTUAL))
# 계획과 실제가 얼마나 어긋나는가 (분)
dev <- as.numeric(difftime(parse_dtc(PC$PCDTC_ACTUAL), parse_dtc(PC$PCDTC),
                           units = "mins"))
summary(dev)
