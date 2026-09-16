# D-최적 탐색. 사람마다 세 번 채혈할 수 있고 시각은 여덟 후보 가운데 고른다면,
# 어느 셋이 정보행렬의 행렬식을 가장 크게 하는가. 후보 56가지를 모두 평가한다.
cand <- c(0.5, 1, 2, 4, 6, 8, 12, 24)
trip <- combn(cand, 3)
ld <- apply(trip, 2, function(tt) { Fi <- fim(list(tt), 30); if (rcond(Fi) < 1e-12) -Inf else log(det(Fi)) })
o <- order(ld, decreasing = TRUE)
best <- data.frame(t1 = trip[1, o[1:5]], t2 = trip[2, o[1:5]], t3 = trip[3, o[1:5]], logdet = round(ld[o[1:5]], 2))
best
# 최적 설계와 이 장의 sparse3 (1, 4, 24) 의 기대 RSE 를 나란히.
rbind(최적 = round(rse_of(list(trip[, o[1]]), 30), 1), sparse3 = round(rse_of(list(c(1, 4, 24)), 30), 1))
# 채혈을 하나 더 주면(넷) 무엇이 좋아지는가. 최적 셋에 후보 하나를 더한 최선.
add <- sapply(setdiff(cand, trip[, o[1]]), function(t4) log(det(fim(list(sort(c(trip[, o[1]], t4))), 30))))
c(넷째_시각 = setdiff(cand, trip[, o[1]])[which.max(add)], logdet = round(max(add), 2))
