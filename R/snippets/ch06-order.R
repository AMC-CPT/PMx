# ID 는 오름차순이어야 한다. 개인별 레코드가 연속이기만 하면 NONMEM 의 추정은
# 통과하므로 이 위반은 오류 없이 지나간다. 뒤의 절차가 조용히 틀어질 뿐이다.
uid <- unique(nm$ID)
c(숫자순 = identical(uid, sort(uid)),
  문자순 = identical(as.character(uid), sort(as.character(uid))))

# 왜 이것이 실제로 깨지는가. 자릿수가 다른 시험을 합치면 문자 정렬이 뒤집는다.
mix <- c("110001", "110002", "20001")   # 6자리 시험 둘 + 5자리 시험 하나
sort(mix)
sort(as.numeric(mix))
