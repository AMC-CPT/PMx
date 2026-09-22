# Fix them and pay the price. Fixing removes one parameter and the OFV rises.
ofv <- function(m) fin(m)[["OBJ"]]
o <- c(both.estimated = ofv("108wt"), V.fixed = ofv("108wts"),
       both.fixed = ofv("108wtx"))
round(rbind(OFV = o, vs.previous = c(NA, diff(o))), 2)

# Put the two thresholds alongside.
c(forward = 3.84, backward = 10.83)
