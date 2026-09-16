# 9번만 320 mg 에서 52 mg 벗어난다. 나머지 11명의 산포는 반올림 탓이다.
round(range(dz$TOTAL[dz$ID != 9]), 2)     # 9번을 뺀 범위
round(320 / dz$WT[dz$ID == 9], 4)         # 9번이 320 mg 이 되려면 필요한 용량
round(3.7 * dz$WT[dz$ID == 9], 2)         # 3.7 로 고치면
