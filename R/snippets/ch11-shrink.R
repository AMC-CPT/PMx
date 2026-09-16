# 수축 둘. eta-shrinkage 는 EBE 의 흩어짐이 OMEGA 보다 얼마나 작은가,
# eps-shrinkage 는 IWRES 의 흩어짐이 1 보다 얼마나 작은가다. NONMEM 이 .lst 에
# 찍는 값(ETASHRINKSD, EPSSHRINKSD)과 손으로 구한 값을 대조한다.
e  <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
f  <- unlist(e[e$ITERATION == -1000000000, -1])
pa <- read.table(nmf("108wt", "patab"), skip = 1, header = TRUE)
pa <- pa[!duplicated(pa$ID), ]
sd <- read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)
sd <- sd[sd$MDV == 0, ]
hand <- c(ETA1 = 1 - sd(pa$ETA1) / sqrt(f[["OMEGA.1.1."]]),
          ETA2 = 1 - sd(pa$ETA2) / sqrt(f[["OMEGA.2.2."]]),
          EPS  = 1 - sd(sd$IWRE))
l   <- readLines(nmf("108wt", "108wt.lst"), warn = FALSE)
pick <- function(tag) as.numeric(strsplit(trimws(sub(tag, "", grep(tag, l, value = TRUE)[1])), " +")[[1]])
nm <- c(pick("ETASHRINKSD\\(%\\)"), pick("EPSSHRINKSD\\(%\\)"))
round(rbind(손으로 = 100 * hand, NONMEM = nm), 1)
