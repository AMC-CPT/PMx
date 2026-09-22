# Whether an input has changed is known from its hash, not from the file
# name or the date. But something must be nailed down before hashes can be
# used at all: **the line ending.**
x <- c("ID,TIME", "1,0")
lf <- tempfile(); crlf <- tempfile()
writeBin(charToRaw(paste0(paste(x, collapse = "\n"),   "\n")),   lf)
writeBin(charToRaw(paste0(paste(x, collapse = "\r\n"), "\r\n")), crlf)

# Not one character of the content differs. The hashes are entirely different.
unname(tools::md5sum(c(lf, crlf)))
c(LF.bytes = file.size(lf), CRLF.bytes = file.size(crlf))

# A real MANIFEST is built like this.
f <- c("data/pheno.csv", list.files("data/sdtm", full.names = TRUE))
man <- data.frame(file = f, md5 = unname(tools::md5sum(f)),
                  bytes = file.size(f))
c(files = nrow(man), hash.length = nchar(man$md5[1]))
