# 제출 package 의 MANIFEST. 파일마다 해시와 크기를 적고, 그 표 자체의 해시를
# 맨 끝에 둔다. 받는 쪽이 한 줄로 전체를 대조할 수 있다(3장).
pkg <- c("data/pheno-nm.csv", "nm/108wt.ctl", "nm/108wt.R76/108wt.lst",
         "nm/108wt.R76/108wt.ext", "R/runnm.R", "R/build.R", "R/boot.R")
man <- data.frame(file = pkg, bytes = file.size(pkg),
                  md5 = unname(tools::md5sum(pkg)))
man
tmp <- tempfile(); write.csv(man, tmp, row.names = FALSE)
c(MANIFEST.md5 = unname(tools::md5sum(tmp)))
