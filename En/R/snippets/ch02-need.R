# Why trimming is not a matter of taste. This is what nmw's termination test
# actually looks like.
body(MinSuccess)

# The file name is fixed too. So we step into that folder to call it.
owd <- setwd(RUN)
res <- c(converged = MinSuccess(), std.errors = SESuccess())
setwd(owd)
res
