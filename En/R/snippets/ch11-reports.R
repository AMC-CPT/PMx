# The eight reports read **committed artifacts only**. They are produced even
# on a PC without NONMEM. That the run folder is nm/<model>.R76/ earns its keep
# here (Ch 3). The model name comes from the folder name, the tables from
# sdtab/patab/cotab/catab, and the termination status from PRINT.OUT.
library(nmw)
nmf <- function(model, file) file.path("nm", paste0(model, ".R76"), file)
RUN <- "nm/108wt.R76"

owd <- setwd(RUN); nmw_run(); setwd(owd)
list.files(RUN, pattern = "(?i)^S.-.*[.]PDF$")
