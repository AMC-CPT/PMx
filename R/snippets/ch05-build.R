# 이제 합친다. 투약 레코드와 관측 레코드를 한 시간축에 세운다.
# ID 는 NONMEM 이 쓸 정수로 새로 매긴다. 열쇠(USUBJID)는 SUBJID 열에 남는다.
nm <- build_nm_dataset(DM = dm, EX = ex, PC = pc, dose_cmt = 1L,
                       id_func = function(u) as.integer(sub("^.*-", "", u)))
dim(nm)

# 레코드 셋. 투여 전 채혈 59건은 MDV=1 로 남아 관측으로 세지 않는다.
table(레코드 = ifelse(nm$AMT > 0, "투약", "채혈"), MDV = nm$MDV)
head(nm, 3)
