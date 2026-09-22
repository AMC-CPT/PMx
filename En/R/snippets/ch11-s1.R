# The numbers S1 puts on its first page. Obtain them by hand and you can check
# them without opening the PDF.
e <- read.table(nmf("108wt", "108wt.ext"), skip = 1, header = TRUE)
f <- unlist(e[e$ITERATION == -1000000000, -1])
d <- read.csv("data/pheno-nm.csv")
nobs <- sum(d$MDV == 0)

c(records = nrow(d), observations = nobs,
  parameters = sum(!names(f) %in% c("OBJ", "SIGMA.1.1.")),   # SIGMA is fixed
  OFV = round(f[["OBJ"]], 3),
  OFV.per.obs = round(f[["OBJ"]] / nobs, 4))
