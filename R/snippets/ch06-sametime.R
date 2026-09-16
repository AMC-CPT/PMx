# 중복 59건이 나왔다. 소견처럼 보이지만 들여다봐야 한다.
key <- paste(nm$ID, dt, nm$CMT)
tie <- key %in% key[duplicated(key)]
table(겹친레코드 = ifelse(nm$EVID[tie] == 1, "투약", "관측"))

# 겹친 것은 전부 관측 하나 + 투약 하나다. 투여 전 채혈이므로 정상이다.
# 그러면 개수가 아니라 **순서**를 봐야 한다. 관측이 투약보다 앞인가.
c(투약이앞선쌍 = sum(tapply(which(tie), key[tie],
                            function(i) any(diff(nm$EVID[i]) < 0))))

head(nm[tie, c("ID", "TIME", "TAFD", "AMT", "DV", "MDV", "EVID")], 4)
