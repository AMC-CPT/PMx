# Begin the time checks. But TIME is not an elapsed time; it is "08:00", and
# the date is separately in DAT2. The common mistake: read TIME as a number.
t_wrong <- suppressWarnings(as.numeric(nm$TIME))
c(NA.fraction = mean(is.na(t_wrong)), negative.time = sum(t_wrong < 0, na.rm = TRUE),
  time.goes.back = sum(unlist(tapply(t_wrong, nm$ID, diff)) < 0, na.rm = TRUE))

# The last two checks returned "no violations". That is because they checked
# nothing. Look again after joining the date and the time into a datetime.
dt <- as.POSIXct(paste(nm$DAT2, nm$TIME), format = "%Y-%m-%d %H:%M", tz = "UTC")
c(missing = sum(is.na(dt)),
  time.goes.back = sum(unlist(tapply(as.numeric(dt), nm$ID, diff)) < 0),
  duplicated = sum(duplicated(paste(nm$ID, dt, nm$CMT))))
