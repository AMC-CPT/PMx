# NONMEM's .lst is FORTRAN output from the line-printer era. Column 1 of each
# line is not a character but a signal sent to the printer.
#   '1' new page,  '0' skip two lines,  '+' **overstrike the previous line**,
#   ' ' one line
# Run artefacts live in a folder of their own per model: nm/<model>.R76/ (Ch 3)
RUN <- "nm/100base.R76"
x  <- readLines(file.path(RUN, "100base.lst"), warn = FALSE)
cc <- substr(x, 1, 1)
c(total = length(x), newpage = sum(cc == "1"), skip2 = sum(cc == "0"),
  overstrike = sum(cc == "+"), plain = sum(cc == " "))

# What overstriking does is plain once you look. Here is the OMEGA matrix.
i <- grep("OMEGA - COV MATRIX", x)[1]
writeLines(x[i:(i + 9)])
