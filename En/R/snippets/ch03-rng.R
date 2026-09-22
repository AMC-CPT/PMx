# Work that uses random numbers records the seed inside the script. But
# **the seed alone is not enough**, because the algorithm of sample()
# changed in R 3.6.0.
RNGkind()                      # the three values in force. Record these too

set.seed(20260914); a <- sample(10)
set.seed(20260914); b <- sample(10)
identical(a, b)                # same R, same seed: identical, of course

# Now switch to the old algorithm and give it the **same seed**.
suppressWarnings(RNGkind(sample.kind = "Rounding"))
set.seed(20260914); old <- sample(10)
RNGkind(sample.kind = "Rejection")            # always put it back

rbind(Rejection = a, Rounding = old)
