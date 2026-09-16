# 입력이 바뀌었는지는 해시로 안다. 파일 이름이나 날짜로는 알 수 없다.
# 그런데 해시를 쓰기 전에 못 박을 것이 있다. **줄바꿈이다.**
x <- c("ID,TIME", "1,0")
lf <- tempfile(); crlf <- tempfile()
writeBin(charToRaw(paste0(paste(x, collapse = "\n"),   "\n")),   lf)
writeBin(charToRaw(paste0(paste(x, collapse = "\r\n"), "\r\n")), crlf)

# 내용은 한 글자도 다르지 않다. 해시는 전혀 다르다.
unname(tools::md5sum(c(lf, crlf)))
c(LF바이트 = file.size(lf), CRLF바이트 = file.size(crlf))

# 실제 MANIFEST 는 이렇게 만든다.
f <- c("data/pheno.csv", list.files("data/sdtm", full.names = TRUE))
man <- data.frame(file = f, md5 = unname(tools::md5sum(f)),
                  bytes = file.size(f))
c(파일수 = nrow(man), 해시길이 = nchar(man$md5[1]))
