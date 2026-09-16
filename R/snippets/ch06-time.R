# 시간 검사를 시작한다. 그런데 TIME 은 경과시간이 아니라 "08:00" 이다.
# 날짜는 DAT2 에 따로 있다. 흔한 실수: TIME 을 그냥 수로 읽는다.
t_wrong <- suppressWarnings(as.numeric(nm$TIME))
c(NA비율 = mean(is.na(t_wrong)), 음수시간 = sum(t_wrong < 0, na.rm = TRUE),
  시간역행 = sum(unlist(tapply(t_wrong, nm$ID, diff)) < 0, na.rm = TRUE))

# 위 두 검사는 '위반 0' 을 돌려주었다. 아무것도 검사하지 않았기 때문이다.
# 날짜와 시각을 합쳐 datetime 을 만든 뒤에 본다.
dt <- as.POSIXct(paste(nm$DAT2, nm$TIME), format = "%Y-%m-%d %H:%M", tz = "UTC")
c(결측 = sum(is.na(dt)),
  시간역행 = sum(unlist(tapply(as.numeric(dt), nm$ID, diff)) < 0),
  중복 = sum(duplicated(paste(nm$ID, dt, nm$CMT))))
