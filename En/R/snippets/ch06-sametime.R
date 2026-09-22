# 59 duplicates came out. It looks like a finding, but it must be looked into.
key <- paste(nm$ID, dt, nm$CMT)
tie <- key %in% key[duplicated(key)]
table(tied.record = ifelse(nm$EVID[tie] == 1, "dose", "observation"))

# Every tie is one observation plus one dose. They are pre-dose samples, so
# this is normal. Then it is not the count but the **order** that must be
# looked at: does the observation come before the dose?
c(pairs.with.dose.first = sum(tapply(which(tie), key[tie],
                                     function(i) any(diff(nm$EVID[i]) < 0))))

head(nm[tie, c("ID", "TIME", "TAFD", "AMT", "DV", "MDV", "EVID")], 4)
