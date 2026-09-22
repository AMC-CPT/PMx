# Read the dataset built in Ch 5. Ch 6 is the chapter that asks whether it is
# right. Read the date and the time as character without fail: TIME is not an
# elapsed time but "08:00".
nm <- read.csv("data/pheno-nm.csv",
               colClasses = c(DAT2 = "character", TIME = "character"))

# Start with the accounting. Does it reconcile with the row counts of the
# source domains?
c(records = nrow(nm), subjects = length(unique(nm$ID)),
  doses = sum(nm$EVID == 1), observations = sum(nm$MDV == 0),
  pre.dose = sum(nm$EVID == 0 & nm$MDV == 1))

c(EX.rows = nrow(read.csv("data/sdtm/ex.csv")),
  PC.rows = nrow(read.csv("data/sdtm/pc.csv")))
