# In data that came through .xpt, a zero is sometimes not a zero. SAS XPORT
# uses IBM hexadecimal floating point, whose smallest magnitude is 16^-65.
# A zero can be read back as that value.
16^-65

# So counting with == 0 finds none of them. One must look at the magnitude.
x <- c(0, 16^-65, 1.2, 0)                    # say this column came from .xpt
c(`x == 0` = sum(x == 0), `abs(x) < 1e-10` = sum(abs(x) < 1e-10))

# Sweep the whole dataset at once, looking for values that are not zero and
# absurdly small.
num <- nm[, sapply(nm, is.numeric)]
c(suspect = sum(sapply(num, function(v) sum(v != 0 & abs(v) < 1e-10, na.rm = TRUE))))
