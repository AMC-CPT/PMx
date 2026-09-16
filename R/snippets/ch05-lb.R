# LB: 크레아티닌. 세 가지가 한꺼번에 걸린다.
#   (i) 검열값이 문자열, (ii) 기관마다 단위, (iii) 기관마다 정상상한.
head(sort(unique(LB$LBORRES)), 5)        # "<0.2" 는 as.numeric() 이 NA 로 만든다

# 정상범위가 결과와 같은 단위로 보고되었는지 먼저 맞춰 본다
u <- merge(unique(LB[, c("SITEID", "LBORRESU")]),
           LN[, c("SITEID", "LBORRESU", "LBORNRHI")],
           by = "SITEID", suffixes = c(".res", ".ref"))
stopifnot(u$LBORRESU.res == u$LBORRESU.ref)
u

LB$SUBJID <- LB$USUBJID
n0 <- nrow(LB)
LB <- merge(LB, LN[, c("SITEID", "LBTESTCD", "LBORNRHI")],
            by = c("SITEID", "LBTESTCD"))
stopifnot(nrow(LB) == n0)

cens     <- grepl("^<", LB$LBORRES)
LB$CENS  <- as.integer(cens)
LB$CREA0 <- suppressWarnings(as.numeric(LB$LBORRES))
stopifnot(all(is.na(LB$CREA0) == cens))  # NA 가 되는 것이 검열값뿐인가. 다른
                                         # 문자열(QNS, HEMOLYZED)이 숨어 있으면 여기서 선다
LB$CREA0[cens] <- as.numeric(sub("^<", "", LB$LBORRES[cens])) / 2   # 한계/2 로 대치

umol <- LB$LBORRESU == "umol/L"          # 1 mg/dL = 88.4 umol/L
LB$CREA  <- ifelse(umol, LB$CREA0 / 88.4, LB$CREA0)
LB$ULN   <- ifelse(umol, as.numeric(LB$LBORNRHI) / 88.4, as.numeric(LB$LBORNRHI))
LB$CREAR <- LB$CREA / LB$ULN             # 정상상한 대비 비

c(전체 = nrow(LB), 검열 = sum(cens))
aggregate(cbind(CREA0, CREA, CREAR) ~ SITEID, LB, function(x) round(mean(x), 2))

# 단위를 맞추면 세 기관이 나란해진다. 그런데 정상상한으로 나눈 비는 다시 벌어진다.
# 상한이 기관마다 달라서다. 어느 쪽을 쓸 것인가는 기관 차이가 '검사'에 있는가
# '단위'에 있는가로 갈린다. 여기서는 단위이므로 환산한 값을 공변량으로 가져간다.
lbc <- LB[, c("SUBJID", "LBDTC", "CREA")]
