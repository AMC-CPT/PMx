# VS: 체중. 방문마다 재므로 시간축이 딸려 온다. 고정할지 시변으로 둘지 정해야 한다.
VS$SUBJID <- VS$USUBJID
VS$BWT    <- as.numeric(VS$VSORRES)
vsw <- VS[VS$VSTESTCD == "WEIGHT", c("SUBJID", "VISIT", "VSDTC", "BWT")]

table(대상자당.측정횟수 = table(vsw$SUBJID))

# 기저(DAY 1) 체중. 시불변으로 다루기로 하면 이 값 하나를 전 레코드에 퍼뜨린다.
vsb <- vsw[vsw$VISIT == "DAY 1", c("SUBJID", "BWT")]
stopifnot(nrow(vsb) == length(unique(vsw$SUBJID)))   # 대상자마다 정확히 하나

r <- vsw$BWT / vsb$BWT[match(vsw$SUBJID, vsb$SUBJID)]    # 기저 대비 체중
c(최소 = min(r), 최대 = round(max(r), 3))
