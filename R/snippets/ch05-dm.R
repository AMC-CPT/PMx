# DM 은 대상자당 한 행이고, 시험 내내 변하지 않는 것만 담는다. 체중은 여기 없다.
names(DM)

# 도메인을 잇는 열쇠는 USUBJID 다. SUBJID 는 기관 안에서만 유일하다.
# nmw 의 조립 함수는 열쇠 열의 이름을 SUBJID 로 요구하므로 거기에 USUBJID 를 담는다.
DM$SUBJID <- DM$USUBJID
DM$SEX    <- code_sex(DM$SEX)      # M=0, F=1. 문서를 믿지 않고 코딩을 고정한다
DM$APGR   <- as.numeric(DM$APGAR)

dm <- DM[, c("SUBJID", "SITEID", "SEX", "APGR")]
head(dm, 3)
