# THEO 의 용량은 전원 320 mg 경구 투여다. 자료에 적힌 것은 mg/kg 이므로
# 체중을 곱해 되돌리면 총 용량이 나온다. 상수여야 할 값이 상수인지 본다.
theo <- read.table("data/theo-raw.txt", na.strings = ".",
                   col.names = c("ID", "DOSE", "TIME", "CP", "WT"))

dz <- unique(theo[!is.na(theo$DOSE), c("ID", "DOSE", "WT")])
dz$TOTAL <- dz$DOSE * dz$WT
dz
