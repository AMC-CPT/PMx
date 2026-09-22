# Every subject in THEO received 320 mg orally. What is recorded in the data is
# mg/kg, so multiplying by body weight gives the total dose back. Check that a
# value which must be constant is constant.
theo <- read.table("data/theo-raw.txt", na.strings = ".",
                   col.names = c("ID", "DOSE", "TIME", "CP", "WT"))

dz <- unique(theo[!is.na(theo$DOSE), c("ID", "DOSE", "WT")])
dz$TOTAL <- dz$DOSE * dz$WT
dz
