# What a sponsor sends is not a finished dataset but domains. Even the
# separators differ, so the reading function differs too (only vs.txt is
# tab-separated). Read every column as character and convert to numeric by hand
# where that column is actually used. Automatic conversion quietly ruins much.
library(nmw)

DM <- read.csv("data/sdtm/dm.csv",      colClasses = "character")  # demographics
EX <- read.csv("data/sdtm/ex.csv",      colClasses = "character")  # dosing
PC <- read.csv("data/sdtm/pc.csv",      colClasses = "character")  # concentration (nominal time)
CO <- read.csv("data/sdtm/pc_coll.csv", colClasses = "character")  # actual sampling time
VS <- read.delim("data/sdtm/vs.txt",    colClasses = "character")  # vital signs (weight)
LB <- read.csv("data/sdtm/lb.csv",      colClasses = "character")  # laboratory (creatinine)
LN <- read.csv("data/sdtm/lb_norm.csv", colClasses = "character")  # normal range by site

sapply(list(DM = DM, EX = EX, PC = PC, CO = CO, VS = VS, LB = LB, LN = LN), nrow)
