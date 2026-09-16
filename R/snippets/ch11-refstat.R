# 그림의 인상을 숫자로. 관측에서 DV 를 PRED 에 회귀한 기울기와, 모의 200회에서
# 같은 기울기의 분포. 관측의 기울기가 모의 분포의 안에 있으면 "모형이 옳을 때
# 나올 수 있는 모양"이다. 기울기가 1 이 아니라는 것 자체는 아무것도 뜻하지 않는다.
slope <- function(d) unname(coef(lm(DV ~ PRED, d))[2])
s_obs <- slope(obs)
pr    <- obs[, c("ID", "TIME", "PRED")]
s_sim <- sapply(split(sim, sim$REP), function(z) slope(merge(z, pr, by = c("ID", "TIME"))))
c(관측 = round(s_obs, 3), 모의중앙 = round(median(s_sim), 3),
  모의5 = round(unname(quantile(s_sim, 0.05)), 3), 모의95 = round(unname(quantile(s_sim, 0.95)), 3),
  관측의위치 = round(mean(s_sim < s_obs), 2))
