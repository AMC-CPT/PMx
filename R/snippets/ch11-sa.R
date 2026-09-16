# SA 는 같은 ID/TIME/MDV 를 가진 레코드를 '잠재적으로 해로운 것'으로 찍는다.
# 우리 자료에는 그런 것이 있다. 6장에서 이미 본 것이다.
sd <- read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)
k  <- paste(sd$ID, sd$TIME, sd$MDV)
c(겹친레코드 = sum(k %in% k[duplicated(k)]))

head(sd[k %in% k[duplicated(k)], c("ID", "TIME", "AMT", "DV", "MDV", "EVID")], 4)
