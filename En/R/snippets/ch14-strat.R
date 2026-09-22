# Whether stratification is needed is something the data tell you. Look at the
# sex composition plain resampling produces.
d   <- read.csv("data/pheno-nm.csv")
uid <- unique(d$ID)
sex <- d$SEX[match(uid, d$ID)]
table(original = sex)

# Over 10000 resamples, how many get SEX=1? No NONMEM needed.
set.seed(20260916)
m <- replicate(10000, sum(sample(sex, length(sex), replace = TRUE)))
c(original = sum(sex), mean = round(mean(m), 1),
  round(quantile(m, c(0.025, 0.975))))
