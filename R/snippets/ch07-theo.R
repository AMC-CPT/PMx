# 두 번째 예제. theophylline 경구 단회 투여, 12명, 대상자당 농도 11개
# (R/mkdata/make_theo.R 이 data/theo-raw.txt 에서 만들었다. 6장의 그 자료다).
th <- read.csv("data/theo-nm.csv", na.strings = ".")
c(대상자 = length(unique(th$ID)), 투약 = sum(th$EVID == 1), 관측 = sum(th$MDV == 0),
  제외 = sum(th$EVID == 0 & th$MDV == 1))
# 시각 0 의 농도가 0 이 아니다. 투여 전 관측이므로 적합에서 뺐다(MDV=1).
round(th$DV[th$EVID == 0 & th$TIME == 0], 2)
