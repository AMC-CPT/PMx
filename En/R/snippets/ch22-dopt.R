# D-optimal search. If each person can be sampled three times and the times are
# chosen from eight candidates, which three maximise the determinant of the
# information matrix? Evaluate all 56.
cand <- c(0.5, 1, 2, 4, 6, 8, 12, 24)
trip <- combn(cand, 3)
ld <- apply(trip, 2, function(tt) { Fi <- fim(list(tt), 30); if (rcond(Fi) < 1e-12) -Inf else log(det(Fi)) })
o <- order(ld, decreasing = TRUE)
best <- data.frame(t1 = trip[1, o[1:5]], t2 = trip[2, o[1:5]], t3 = trip[3, o[1:5]], logdet = round(ld[o[1:5]], 2))
best
# The optimal design and this chapter's sparse3 (1, 4, 24), expected RSEs side by side.
rbind(optimal = round(rse_of(list(trip[, o[1]]), 30), 1),
      sparse3 = round(rse_of(list(c(1, 4, 24)), 30), 1))
# What does one more sample (a fourth) buy? The best candidate added to the
# optimal three.
add <- sapply(setdiff(cand, trip[, o[1]]), function(t4) log(det(fim(list(sort(c(trip[, o[1]], t4))), 30))))
c(fourth.time = setdiff(cand, trip[, o[1]])[which.max(add)], logdet = round(max(add), 2))
