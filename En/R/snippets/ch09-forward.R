# Forward selection. Add one at a time to the base model and see how far the
# OFV falls. The models are nested, so a chi-square on 1 df applies; the
# forward threshold is 3.84 (p<0.05).
fin <- function(m) {
  e <- read.table(nmf(m, paste0(m, ".ext")), skip = 1, header = TRUE)
  unlist(e[e$ITERATION == -1000000000, -1])
}
ofv <- function(m) fin(m)[["OBJ"]]

step1 <- c(base = ofv("100base"), WT.on.CL = ofv("106wtcl"), WT.on.V = ofv("107wtv"))
round(rbind(OFV = step1, dOFV = step1 - step1[["base"]]), 2)

# Weight on V brought it down further. Take one more step from there.
step2 <- c(WT.on.V = ofv("107wtv"), both = ofv("108wt"))
round(c(dOFV = diff(step2), threshold = 3.84), 2)
