# 점검은 "자료가 무엇이어야 하는가"를 코드로 적는 일이다. 어긴 건수를 센다.
# 검사 하나는 대개 한 줄이다. 어려워서 안 하는 것이 아니라 안 해서 안 한다.
check_nm <- function(d) {
  dt  <- as.POSIXct(paste(d$DAT2, d$TIME), format = "%Y-%m-%d %H:%M", tz = "UTC")
  key <- paste(d$ID, dt, d$CMT)
  byid <- function(f) tapply(seq_len(nrow(d)), d$ID, f)
  v <- c(
    "ID 가 오름차순이 아니다"       = as.integer(is.unsorted(d$ID)),
    "대상자 레코드가 흩어져 있다"   = sum(table(rle(d$ID)$values) > 1),
    "datetime 이 NA"                = sum(is.na(dt)),
    "TAFD 가 음수"                  = sum(d$TAFD < 0),
    "대상자 안에서 TAFD 가 역행"    = sum(unlist(byid(function(i) diff(d$TAFD[i]))) < 0),
    "TAFD 가 datetime 과 어긋난다"  = sum(byid(function(i) {
        e <- (as.numeric(dt[i]) - min(as.numeric(dt[i]))) / 3600 -
             (d$TAFD[i] - min(d$TAFD[i]))
        isTRUE(any(abs(e) > 1e-6)) })),   # dt 가 NA 면 위 검사가 이미 잡는다
    "같은 시각에 같은 종류가 중복"  = sum(duplicated(paste(key, d$EVID))),
    "같은 시각인데 투약이 앞"       = sum(tapply(seq_along(key), key,
                                            function(i) any(diff(d$EVID[i]) < 0))),
    "투약인데 AMT 가 0 이하"        = sum(d$EVID == 1 & !(d$AMT > 0)),
    "관측인데 AMT 가 0 이 아니다"   = sum(d$EVID == 0 & d$AMT != 0),
    "MDV=0 인데 DV 가 없다"         = sum(d$MDV == 0 & is.na(d$DV)),
    "공변량에 결측"                 = sum(!complete.cases(d[, c("WT","SEX","APGR","CREA")])),
    "시불변 공변량이 상수가 아니다" = sum(byid(function(i) length(unique(d$WT[i]))) > 1),
    "첫 관측이 첫 투약보다 앞"      = sum(byid(function(i) {
        o <- d$TAFD[i][d$MDV[i] == 0]; x <- d$TAFD[i][d$EVID[i] == 1]
        length(o) > 0 && length(x) > 0 && min(o) < min(x) }))
  )
  if (all(v == 0)) cat(sprintf("점검 %d건, 위반 없음\n", length(v))) else print(v[v > 0])
  invisible(v)
}

check_nm(nm)
