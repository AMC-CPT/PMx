# 난수를 쓰는 작업은 seed 를 스크립트 안에 적는다. 그런데 **seed 만으로는
# 부족하다.** R 3.6.0 에서 sample() 의 알고리즘이 바뀌었기 때문이다.
RNGkind()                      # 지금 쓰는 세 값. 이것을 함께 적어야 한다

set.seed(20260914); a <- sample(10)
set.seed(20260914); b <- sample(10)
identical(a, b)                # 같은 R 에서 같은 seed 면 당연히 같다

# 옛 알고리즘으로 바꾸고 **같은 seed** 를 준다.
suppressWarnings(RNGkind(sample.kind = "Rounding"))
set.seed(20260914); old <- sample(10)
RNGkind(sample.kind = "Rejection")            # 반드시 되돌린다

rbind(Rejection = a, Rounding = old)
