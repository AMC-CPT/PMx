# 5장이 만든 데이터셋을 읽는다. 6장은 이것이 옳은지 묻는 장이다.
# 날짜와 시각은 반드시 문자로 읽는다. TIME 은 경과시간이 아니라 "08:00" 이다.
nm <- read.csv("data/pheno-nm.csv",
               colClasses = c(DAT2 = "character", TIME = "character"))

# 회계부터 한다. 원천 도메인의 행 수와 맞아떨어지는가.
c(레코드 = nrow(nm), 대상자 = length(unique(nm$ID)),
  투약 = sum(nm$EVID == 1), 관측 = sum(nm$MDV == 0),
  투여전 = sum(nm$EVID == 0 & nm$MDV == 1))

c(EX행 = nrow(read.csv("data/sdtm/ex.csv")),
  PC행 = nrow(read.csv("data/sdtm/pc.csv")))
