# A categorical coding is written only as prose in the dictionary and the
# report. No computation consumes that sentence, so every number can be right
# while the labels alone are reversed. So do not compare a document with a
# document: **derive the coding independently from the data**.
set.seed(6)
n <- 20
cov <- data.frame(AGE = round(runif(n, 20, 70)), BWT = round(runif(n, 50, 90), 1),
                  SEX = rep(0:1, each = n / 2), CREA = round(runif(n, 0.6, 1.2), 2))

# The sponsor also sent a CRCL column. Which sex coding it was computed with is
# not recorded. (This one line is ours, put in for the illustration; in reality
# only the CRCL column arrives.)
cov$CRCL <- with(cov, (140 - AGE) * BWT * ifelse(SEX == 0, 0.85, 1) / (72 * CREA))

# Work it backwards. Divide by the Cockcroft-Gault expression without the 0.85
# female factor and only one of two values can come out.
r <- with(cov, round(CRCL / ((140 - AGE) * BWT / (72 * CREA)), 3))
table(SEX = cov$SEX, factor = r)
