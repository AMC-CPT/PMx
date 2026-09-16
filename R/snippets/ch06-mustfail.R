# 통과만 본 검사는 아무것도 검사하지 않았을 수 있다(앞의 as.numeric 이 그랬다).
# 그래서 검사기를 믿기 전에 **먼저 실패시켜 본다**. 셋을 일부러 어긴다.
d1 <- nm; d1$ID[d1$ID == 7] <- 70              # ID 순서를 흐트러뜨린다
d2 <- nm; d2$WT[d2$ID == 3][1] <- 9.9          # 시불변 공변량을 한 자리만 바꾼다
d3 <- nm; d3$TIME <- sub(":", ".", d3$TIME)    # 시각 형식을 망가뜨린다

broken <- list("ID 순서" = d1, "시불변 공변량" = d2, "시각 형식" = d3)
for (k in names(broken)) {
  cat("\n-- 어긴 것:", k, "\n")
  check_nm(broken[[k]])
}
