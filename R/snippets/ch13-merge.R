# 순열 검정은 공변량을 대상자들 사이에서 섞는다. 그 한 줄에 실제로 있었던
# 오류가 숨어 있다. 시험 둘을 합쳐 ID 자릿수가 다른 경우로 보인다(6장).
ex <- data.frame(
  ID   = c(rep("20001", 2), rep("110001", 3), rep("110002", 2)),
  TIME = c(0, 1, 0, 1, 2, 0, 1),
  WT   = c(60, 60, 70, 70, 70, 80, 80))
uid <- unique(ex$ID)                      # 숫자 순서: 20001, 110001, 110002
set.seed(4)
perm <- data.frame(ID = uid, WT = sample(ex$WT[match(uid, ex$ID)]))
perm

# (1) merge 로 붙이고 그 열을 원래 자료에 넣는다. 흔히 쓰는 방식이다.
m <- merge(ex[, c("ID", "TIME")], perm, by = "ID")   # 문자 ID 로 재정렬된다
bad <- ex; bad$WT <- m$WT

# (2) match 로 붙인다. 행 순서를 보존한다.
good <- ex; good$WT <- perm$WT[match(ex$ID, perm$ID)]

cbind(ex[, c("ID", "TIME")], merge로 = bad$WT, match로 = good$WT)
