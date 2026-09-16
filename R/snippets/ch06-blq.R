# DV = 0 은 셋 중 하나다. 결측, BLQ(재었는데 한계 아래), 선험적 0(투여 전).
# 셋을 끝까지 갈라서 센다. 섞으면 BLQ 비율이 부풀고 M1/M3 판단 자체가 틀어진다.
pc <- read.csv("data/sdtm/pc.csv")
LLOQ <- pc$PCLLOQ[1]
cls <- ifelse(pc$PCREASND == "PREDOSE", "선험적0",
       ifelse(is.na(pc$PCSTRESN), "결측",
       ifelse(pc$PCSTRESN < LLOQ, "BLQ", "정량")))
table(cls)

# BLQ 비율의 분모는 '정량 + BLQ' 다. 선험적 0 은 분자에도 분모에도 들지 않는다.
meas <- cls %in% c("정량", "BLQ")
c(분모 = sum(meas), BLQ = sum(cls == "BLQ"),
  비율 = round(100 * mean(cls[meas] == "BLQ"), 1))

# 선험적 0 을 BLQ 로 함께 세면 이렇게 부푼다. 0 % 가 이 값으로 보고된다.
c(섞어세면 = round(100 * mean(cls %in% c("BLQ", "선험적0")), 1))
