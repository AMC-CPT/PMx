# The row name and its value sit on different lines. On a printer they would
# have been overstruck into one. TrimOut() does that job for us.
library(nmw)
TrimOut(file.path(RUN, "100base.lst"), file.path(RUN, "PRINT.OUT"))

p <- readLines(file.path(RUN, "PRINT.OUT"), warn = FALSE)
c(orig.lines = length(x), trimmed.lines = length(p),
  orig.ctrl = sum(substr(x, 1, 1) %in% c("1", "0", "+")),
  left.ctrl = sum(substr(p, 1, 1) %in% c("1", "0", "+")))

j <- grep("OMEGA - COV MATRIX", p)[1]
writeLines(p[j:(j + 7)])
