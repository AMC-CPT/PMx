# 경과시간(h)을 파생한다. 첫 투약이 0 이다.
clock <- dat2_time_to_posix(nm$DAT2, nm$TIME)
t0 <- tapply(as.numeric(clock)[nm$AMT > 0], nm$SUBJID[nm$AMT > 0], min)
nm$TAFD <- round((as.numeric(clock) - t0[nm$SUBJID]) / 3600, 4)
nm$EVID <- ifelse(nm$AMT > 0, 1L, 0L)

# 같은 시각의 레코드는 조립 때의 순서를 지킨다(투여 전 채혈이 투약보다 앞).
nm <- nm[order(nm$ID, nm$TAFD), ]

# 시간축은 DAT2(날짜) + TIME(시:분) 으로 싣는다. NONMEM 이 이것을 경과시간으로
# 번역한다. 우리가 파생한 TAFD 를 함께 실어 그 번역을 검증할 수 있게 둔다.
NMDS <- data.frame(ID = nm$ID, DAT2 = nm$DAT2, TIME = nm$TIME,
                   AMT = nm$AMT, RATE = nm$RATE, CMT = nm$CMT,
                   DV = nm$DV, MDV = nm$MDV, EVID = nm$EVID,
                   WT = nm$WT, BWT = nm$BWT, SEX = nm$SEX, APGR = nm$APGR,
                   CREA = round(nm$CREA, 3), TAFD = nm$TAFD)
head(NMDS, 4)
