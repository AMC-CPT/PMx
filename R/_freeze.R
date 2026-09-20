# =====================================================================
#  R/_freeze.R  -  helper to freeze R console output and figures
#
#  freeze(name, seed, fig, fig.w, fig.h)
#    - sources R/snippets/<name>.R with a fixed seed
#    - captures VISIBLE console results (not echoed code) to output/<name>.txt
#      (the code itself is shown in the book straight from the snippet file,
#       so code and output can never drift apart)
#    - if fig=TRUE, the snippet's plot is written to figures/<name>.pdf
#
#  Keeps the book build pure-LaTeX while R sources stay the single source
#  of truth, regenerable on demand:  Rscript R/build.R  (run from repo root)
# =====================================================================

# ggplot/patchwork(예: ggsurvfit + add_risktable)는 pdf 장치에 빈 첫 페이지를
# 만들 수 있다.  다중 페이지 그림은 마지막 페이지만 남긴다(그 페이지에 실제
# 그림이 있다).  poppler 의 pdfinfo/pdftocairo 를 쓴다 (MiKTeX 에 포함).
.trim_fig <- function(figfile) {
  pinfo <- Sys.which("pdfinfo"); pcairo <- Sys.which("pdftocairo")
  if (pinfo == "" || pcairo == "") return(invisible())
  out <- tryCatch(system2(pinfo, shQuote(figfile), stdout = TRUE),
                  error = function(e) character())
  # useBytes: pdfinfo 가 시스템 로캘로 답하므로(한글 글꼴 이름이 섞인다)
  # 그대로 grep 하면 "unable to translate ... to a wide string" 경고가 난다.
  m <- grep("^Pages:", out, value = TRUE, useBytes = TRUE)
  npg <- if (length(m)) suppressWarnings(as.integer(sub("^Pages:\\s*", "", m[1]))) else NA
  if (!is.na(npg) && npg > 1) {
    tmp <- paste0(figfile, ".tmp")
    system2(pcairo, c("-pdf", "-f", npg, "-l", npg, shQuote(figfile), shQuote(tmp)))
    if (file.exists(tmp)) {
      file.remove(figfile); file.rename(tmp, figfile)
      message(sprintf("  trimmed blank page(s): %s (kept last of %d)", figfile, npg))
    }
  }
  .crop_fig(figfile)
  invisible()
}

#  둘레의 빈 여백을 잘라 낸다 (2026-09-20).
#  R 그래픽 장치는 fig.w x fig.h 판을 만들고 그 안에 그림을 그리므로, 그림이 판을
#  다 채우지 않으면 둘레에 흰 자리가 남는다. 본문의 그림 폭은 잘라 낸 뒤의 크기에
#  맞추어 두었으므로(인쇄된 그림 크기는 그대로다) 여기서 자르지 않으면 그림이
#  작아져 보인다. 2bp 는 잉크가 글에 닿지 않을 만큼의 최소 여백이다.
.crop_fig <- function(figfile) {
  pcrop <- Sys.which("pdfcrop")
  if (pcrop == "") return(invisible())
  tmp <- paste0(figfile, ".crop")
  ok <- tryCatch(system2(pcrop, c("--margins", "2", shQuote(figfile), shQuote(tmp)),
                         stdout = FALSE, stderr = FALSE),
                 error = function(e) 1L)
  if (identical(as.integer(ok), 0L) && file.exists(tmp)) {
    file.remove(figfile); file.rename(tmp, figfile)
  } else if (file.exists(tmp)) {
    file.remove(tmp)
  }
  invisible()
}

# ---------------------------------------------------------------------
#  긴 출력 성분의 부분 생략 (trim=)
#
#  wnl::nlr 같은 적합 함수는 결과 리스트에 관측치 수만큼의 $Prediction·
#  $Residual 벡터를 담는다. 이를 그대로 인쇄하면 한 출력이 130줄을 넘어
#  지면 대부분을 같은 숫자의 반복으로 채운다(SAS 교재도 핵심 출력만 싣는다).
#  freeze(..., trim = c("Prediction", "Residual")) 로 선언하면, 그 성분의
#  머리줄과 앞 trim.keep 줄만 남기고 나머지를 잘라 낸 뒤 생략 표시를 붙인다.
#  성분을 통째로 지우지 않으므로 독자는 그 성분이 무엇이고 값이 어떤 모양인지
#  볼 수 있고, 지면에 생략 사실도 드러나므로 오해가 없다.
.trim_blocks <- function(txt, trim, trim.keep = 2L) {
  if (!length(trim)) return(txt)
  hdr <- grepl("^\\$", txt)                       # 리스트 성분 머리줄
  keep <- rep(TRUE, length(txt))
  marks <- character(length(txt))
  for (nm in trim) {
    pat   <- paste0("^\\$`?", nm, "`?$")          # 예: $Prediction
    child <- paste0("^\\$`?", nm, "`?\\$")        # 예: $Prediction$x (하위 성분)
    for (s in which(grepl(pat, txt))) {
      nxt <- which(hdr & seq_along(txt) > s & !grepl(child, txt))
      e <- if (length(nxt)) min(nxt) - 1L else length(txt)
      # 머리줄(s)과 그 뒤 '값이 있는' trim.keep 줄까지 남기고, 그다음부터 e 까지
      # 통째로 자른다(하위 성분이 남긴 빈 줄까지 함께 지워야 빈 줄이 몰리지 않는다).
      body <- (s + 1L):e
      body <- body[nzchar(trimws(txt[body]))]     # 값이 있는 줄만 센다
      if (length(body) > trim.keep) {
        keep[body[trim.keep + 1L]:e] <- FALSE
        marks[body[trim.keep]] <- "  ... (이하 생략)"
      }
    }
  }
  out <- character(0)
  for (i in seq_along(txt)) {
    if (keep[i]) out <- c(out, txt[i])
    if (nzchar(marks[i])) out <- c(out, marks[i], "")   # 다음 성분과 한 줄 띄운다
  }
  # 잘라 낸 자리에 빈 줄이 겹칠 수 있으므로 연속 빈 줄은 하나로 줄인다.
  blank <- !nzchar(trimws(out))
  out[!(blank & c(FALSE, head(blank, -1)))]
}

# ---------------------------------------------------------------------
#  성분 통째 제거 (drop=)
#
#  부분 생략(trim=)과 달리 성분을 아예 지운다. 본문이 한 줄뿐이어서 부분
#  생략이 뜻이 없고, 값 자체가 지면에 실릴 값어치가 없는 성분에 쓴다.
#  현재 쓰는 곳: nlr() 의 $`Elapsed Time` - 실행마다 값이 달라져 고정 출력의
#  재현성을 깨는 유일한 항목이었다(ch14 의 Sys.time() 출력을 제거한 것과 같은 이유).
.drop_blocks <- function(txt, drop) {
  if (!length(drop)) return(txt)
  hdr <- grepl("^\\$", txt)
  keep <- rep(TRUE, length(txt))
  for (nm in drop) {
    pat   <- paste0("^\\$`?", nm, "`?$")
    child <- paste0("^\\$`?", nm, "`?\\$")
    for (s in which(grepl(pat, txt))) {
      nxt <- which(hdr & seq_along(txt) > s & !grepl(child, txt))
      e <- if (length(nxt)) min(nxt) - 1L else length(txt)
      keep[s:e] <- FALSE
    }
  }
  txt[keep]
}

# ---------------------------------------------------------------------
#  빈 줄 제거 (squeeze=)
#
#  R 은 리스트를 인쇄할 때 성분마다 빈 줄을 넣는다. 성분이 20개에 가까운
#  nlr() 결과에서는 그 빈 줄만으로 20줄가까이 되므로, 지면에서는 없는 편이
#  낫다. 각 성분이 '$이름' 머리줄로 시작하므로 빈 줄이 없어도 경계가 뚜렷하다.
.squeeze_blanks <- function(txt) txt[nzchar(trimws(txt))]

# Shared session environment: snippets run in order (like a real R session)
# so later snippets can use variables/objects defined by earlier ones within
# the same chapter (e.g. lh2, Lik, t1).  Reset between chapters with new_session().
.session <- new.env(parent = globalenv())
new_session <- function() .session <<- new.env(parent = globalenv())

freeze <- function(name, seed = 1L, fig = FALSE, fig.w = 5, fig.h = 3.2,
                   width = 76, digits = 7, env = .session,
                   trim = NULL, trim.keep = 2L, drop = NULL, squeeze = FALSE) {
  snippet <- file.path("R", "snippets", paste0(name, ".R"))
  outfile <- file.path("output", paste0(name, ".txt"))
  figfile <- file.path("figures", paste0(name, ".pdf"))
  stopifnot(file.exists(snippet))

  old <- options(width = width, digits = digits)
  on.exit(options(old), add = TRUE)
  set.seed(seed)

  # 그림의 글꼴: 본문 sans(KoPubWorld돋움체)와 같은 서체를 쓴다.  pyfig/ 의
  # matplotlib 그림 22점도 같은 글꼴이므로, 한글이 든 그림 전체의 서체가 통일된다.
  # (cairo 는 이 글꼴을 CairoFont-* 이름으로 재내장하므로 pdffonts 출력에는
  #  KoPubWorld 라는 이름이 보이지 않는다 - 한글 렌더는 정상이다.)
  # cairo 가 없는 환경에서는 pdf() 로 떨어지며 한글이 깨질 수 있다.
  if (fig) {
    if (capabilities("cairo")) grDevices::cairo_pdf(figfile, width = fig.w, height = fig.h, family = "KoPubWorld돋움체 Medium")
    else grDevices::pdf(figfile, width = fig.w, height = fig.h)
    on.exit({ if (length(grDevices::dev.list())) grDevices::dev.off() }, add = TRUE)
  }

  txt <- utils::capture.output(
    source(snippet, echo = FALSE, print.eval = TRUE, keep.source = FALSE,
           local = env)
  )
  txt <- .drop_blocks(txt, drop)
  txt <- .trim_blocks(txt, trim, trim.keep)
  if (squeeze) txt <- .squeeze_blanks(txt)
  writeLines(txt, outfile)
  if (fig) { if (length(grDevices::dev.list())) grDevices::dev.off()
             .trim_fig(figfile) }
  message(sprintf("  frozen: %-26s -> %s%s", snippet, outfile,
                  if (fig) paste0(" + ", figfile) else ""))
  invisible(txt)
}
