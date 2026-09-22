# The MANIFEST of a submission package. Record a hash and a size for each file,
# and put the hash of the table itself at the end, so that the receiving side
# can check the whole thing against one line (Ch 3).
pkg <- c("data/pheno-nm.csv", "nm/108wt.ctl", "nm/108wt.R76/108wt.lst",
         "nm/108wt.R76/108wt.ext", "R/runnm.R", "R/build.R", "R/boot.R")
man <- data.frame(file = pkg, bytes = file.size(pkg),
                  md5 = unname(tools::md5sum(pkg)))
man
tmp <- tempfile(); write.csv(man, tmp, row.names = FALSE)
c(MANIFEST.md5 = unname(tools::md5sum(tmp)))
