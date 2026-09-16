# 18장 둘째 예제. 원숭이 50마리에 단클론항체를 정맥 bolus 로 한 번, 여섯 용량 수준.
# 저자가 실무에서 분석한 자료를 개발 코드와 동물 번호만 지우고 실었다(R/mkdata/make_tmdd.R).
# 농도는 mg/L, 시간은 h, 용량은 mg/kg 이고 AMT 는 실제 투여량(mg)이다.
d <- read.csv("data/tmdd-mab.csv")
obs <- d[d$MDV == 0, ]
s <- d[!duplicated(d$ID), ]
data.frame(용량_mgkg = sort(unique(s$LVL)), 마리 = as.vector(table(s$LVL)),
           체중_kg = tapply(s$BWT, s$LVL, function(x) sprintf("%.1f-%.1f", min(x), max(x))),
           row.names = NULL)
c(관측 = nrow(obs), 채혈시각 = length(unique(obs$TIME)), 마지막시각_h = max(obs$TIME),
  최저농도 = min(obs$DV))
