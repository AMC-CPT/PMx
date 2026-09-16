# 의뢰사가 보내오는 것은 완성된 데이터셋이 아니라 도메인들이다. 구분자도 제각각이라
# 읽는 함수부터 다르다(vs.txt 만 탭 구분). 모든 열을 문자로 읽고, 수치 변환은
# 그 열을 쓰기로 정한 자리에서 손으로 한다. 자동 변환이 조용히 망치는 것이 많다.
library(nmw)

DM <- read.csv("data/sdtm/dm.csv",      colClasses = "character")  # 인구학
EX <- read.csv("data/sdtm/ex.csv",      colClasses = "character")  # 투약
PC <- read.csv("data/sdtm/pc.csv",      colClasses = "character")  # 농도(계획시각)
CO <- read.csv("data/sdtm/pc_coll.csv", colClasses = "character")  # 실채혈시각
VS <- read.delim("data/sdtm/vs.txt",    colClasses = "character")  # 활력징후(체중)
LB <- read.csv("data/sdtm/lb.csv",      colClasses = "character")  # 검사(크레아티닌)
LN <- read.csv("data/sdtm/lb_norm.csv", colClasses = "character")  # 기관별 정상범위

sapply(list(DM = DM, EX = EX, PC = PC, CO = CO, VS = VS, LB = LB, LN = LN), nrow)
