# EX: 투약. 조립 함수는 시각을 DAT2(날짜)와 TIME(시:분)으로 나누어 받는다.
# 벽시계 시각을 그대로 끌고 가는 것이 요점이다. 경과시간은 맨 마지막에 파생한다.
table(경로 = EX$EXROUTE, 단위 = EX$EXDOSU)   # 섞여 있지 않은지 먼저 본다

EX$SUBJID <- EX$USUBJID
tEX <- parse_dtc(EX$EXSTDTC)
EX$DAT2 <- format(tEX, "%Y-%m-%d")
EX$TIME <- format(tEX, "%H:%M")
EX$AMT  <- as.numeric(EX$EXDOSE)
EX$RATE <- 0                       # 정맥 bolus. 주입이면 AMT/주입시간 을 넣는다

ex <- EX[, c("SUBJID", "DAT2", "TIME", "AMT", "RATE")]
head(ex, 3)
