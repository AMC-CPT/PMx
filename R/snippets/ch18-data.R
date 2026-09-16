# 18장의 자료. warfarin 형 PK/PD 모의 자료, 40명, 100 mg 경구 단회.
# 참값을 알고 만들었다(R/mkdata/make_warf.R). 농도와 PCA 를 같은 파일에 DVID 로 구분한다.
d <- read.csv("data/warf-sim.csv", na.strings = ".")
obs <- d[d$MDV == 0, ]
table(종류 = c("농도", "PCA")[obs$DVID])
tr <- read.csv("data/warf-sim-truth.csv"); truth <- setNames(tr$value, tr$name)
round(truth, 3)

# 기저치(시각 0 의 PCA)와 최저치. 회복까지 며칠 걸리는가.
pca <- obs[obs$DVID == 2, ]
m <- tapply(pca$DV, pca$TIME, mean)
round(m, 1)
