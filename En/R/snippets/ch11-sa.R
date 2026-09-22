# SA flags records sharing an ID/TIME/MDV as 'potentially harmful'. Our data
# have some. We already saw them in Ch 6.
sd <- read.table(nmf("108wt", "sdtab"), skip = 1, header = TRUE)
k  <- paste(sd$ID, sd$TIME, sd$MDV)
c(overlapping.records = sum(k %in% k[duplicated(k)]))

head(sd[k %in% k[duplicated(k)], c("ID", "TIME", "AMT", "DV", "MDV", "EVID")], 4)
