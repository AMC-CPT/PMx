# 관측 레코드. 시간축은 실채혈시각으로 세운다.
tPC <- parse_dtc(PC$PCDTC_ACTUAL)
PC$DAT2 <- format(tPC, "%Y-%m-%d")
PC$TIME <- format(tPC, "%H:%M")
PC$DV   <- as.numeric(PC$PCSTRESN)
PC$CMT  <- 1L                                    # 중심구획

# 투여 전 채혈은 측정 결과가 아니라 설계가 보장하는 0 이다. 관측으로 세지 않는다.
table(PREDOSE = PC$PCREASND == "PREDOSE", DV.0 = PC$DV == 0)

# BLQ 는 실제로 재서 정량한계 아래로 나온 값이다. 투여 전 0 은 분자에도 분모에도
# 넣지 않는다(6장의 BLQ 실태 표에서 둘을 분리한다).
post <- PC[PC$PCREASND != "PREDOSE", ]
c(관측 = nrow(post), BLQ = sum(post$DV < as.numeric(post$PCLLOQ)),
  LLOQ = as.numeric(post$PCLLOQ[1]))

pc <- PC[, c("SUBJID", "DAT2", "TIME", "DV", "CMT")]
