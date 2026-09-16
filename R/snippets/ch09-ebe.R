# 실행 산출물은 모형마다 제 폴더에 있다: nm/<모형>.R76/ (3장)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)

# 공변량 탐색은 EBE 를 공변량에 대해 그려 보는 데서 시작한다.
# 기저 모형의 ETA 가 어떤 공변량을 따라 기울어 있으면, 그 공변량이 설명할
# 몫을 지금은 ETA 가 떠안고 있다는 뜻이다.
pa <- read.table(nmf("100base", "patab"), skip = 1, header = TRUE)
co <- read.table(nmf("100base", "cotab"), skip = 1, header = TRUE)
s  <- merge(pa[!duplicated(pa$ID), ], co[!duplicated(co$ID), ], by = "ID")

round(cor(s[, c("ETA1", "ETA2")], s[, c("WT", "CREA", "APGR")]), 3)
