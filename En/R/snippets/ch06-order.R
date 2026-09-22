# ID must be in ascending order. NONMEM's estimation passes as long as each
# individual's records are contiguous, so this violation goes by without an
# error. Only the procedures downstream quietly go wrong.
uid <- unique(nm$ID)
c(numeric.order = identical(uid, sort(uid)),
  string.order  = identical(as.character(uid), sort(as.character(uid))))

# Why does this actually break? Pool studies with different digit counts and
# string sorting reverses the order.
mix <- c("110001", "110002", "20001")   # two six-digit studies + one five-digit
sort(mix)
sort(as.numeric(mix))
