# 증상은 이것이다. 시불변이어야 할 공변량이 한 사람 안에서 여러 값이 된다.
nval <- function(d) tapply(d$WT, d$ID, function(x) length(unique(x)))
rbind(merge로 = nval(bad), match로 = nval(good))

# 그래서 섞은 **직후에** 두 가지를 확인한다. 값이 틀어지면 여기서 선다.
check_perm <- function(d, orig) {
  stopifnot(all(tapply(d$WT, d$ID, function(x) length(unique(x))) == 1),
            identical(sort(unique(d$WT)), sort(unique(orig$WT))))
  "통과"
}
c(match로 = check_perm(good, ex))
c(merge로 = tryCatch(check_perm(bad, ex), error = function(e) "실패"))
