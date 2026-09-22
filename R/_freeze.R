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

# ggplot/patchwork (e.g. ggsurvfit + add_risktable) can produce a blank first
# page on the pdf device. For a multi-page figure only the last page is kept
# (that is the page with the figure). Uses poppler's pdfinfo/pdftocairo (shipped with MiKTeX).
.trim_fig <- function(figfile) {
  pinfo <- Sys.which("pdfinfo"); pcairo <- Sys.which("pdftocairo")
  if (pinfo == "" || pcairo == "") return(invisible())
  out <- tryCatch(system2(pinfo, shQuote(figfile), stdout = TRUE),
                  error = function(e) character())
  # useBytes: pdfinfo answers in the system locale (font names in the local
  # script get mixed in), so a plain grep warns "unable to translate ... to a
  # wide string".
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

#  Crop the blank margin around the figure (2026-09-20).
#  The R graphics device makes a fig.w x fig.h canvas and draws inside it, so
#  whatever the figure does not fill stays as white border. The figure widths
#  in the text are set to the cropped size (the printed size is unchanged), so
#  without cropping here the figure looks smaller. 2bp is the least margin  that keeps ink off the text.
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
#  Partial elision of long output components (trim=)
#
#  A fitting function such as wnl::nlr puts $Prediction and $Residual vectors
#  as long as the number of observations into its result list. Printed as is,
#  one output runs past 130 lines and fills the page with repetition (SAS  textbooks print only the essential output too).
#  Declaring freeze(..., trim = c("Prediction", "Residual")) keeps the
#  header line of that component and the first trim.keep lines, cuts the rest
#  and marks the elision. The component is not removed, so the reader can see
#  what it is and what its values look like, and the elision is visible on  the page, so there is no misunderstanding.
.trim_blocks <- function(txt, trim, trim.keep = 2L) {
  if (!length(trim)) return(txt)
  hdr <- grepl("^\\$", txt)                       # header line of a list component
  keep <- rep(TRUE, length(txt))
  marks <- character(length(txt))
  for (nm in trim) {
    pat   <- paste0("^\\$`?", nm, "`?$")          # e.g. $Prediction
    child <- paste0("^\\$`?", nm, "`?\\$")        # e.g. $Prediction$x (sub-component)
    for (s in which(grepl(pat, txt))) {
      nxt <- which(hdr & seq_along(txt) > s & !grepl(child, txt))
      e <- if (length(nxt)) min(nxt) - 1L else length(txt)
      # Keep the header (s) and the following trim.keep lines that carry
      # values, then cut everything through e (the blank lines left by
      # sub-components go too, or blanks pile up).
      body <- (s + 1L):e
      body <- body[nzchar(trimws(txt[body]))]     # count only lines with values
      if (length(body) > trim.keep) {
        keep[body[trim.keep + 1L]:e] <- FALSE
        marks[body[trim.keep]] <- "  ... (remainder omitted)"
      }
    }
  }
  out <- character(0)
  for (i in seq_along(txt)) {
    if (keep[i]) out <- c(out, txt[i])
    if (nzchar(marks[i])) out <- c(out, marks[i], "")   # one blank line before the next component
  }
  # Blank lines can pile up where the cut was, so runs of them are reduced to one.
  blank <- !nzchar(trimws(out))
  out[!(blank & c(FALSE, head(blank, -1)))]
}

# ---------------------------------------------------------------------
#  Removing a component entirely (drop=)
#
#  Unlike partial elision (trim=), the component is removed altogether. Used
#  where the body is one line so elision is pointless and the value is not  worth printing.
#  Currently used for nlr()'s $`Elapsed Time`: the value differs on every run
#  and it was the one item breaking the reproducibility of the frozen output  (the same reason the Sys.time() output of ch14 was removed).
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
#  Removing blank lines (squeeze=)
#
#  R puts a blank line after each component when printing a list. In an
#  nlr() result with close to twenty components those blanks alone come to
#  nearly twenty lines, so the page is better without them. Each component  starts with a '$name' header, so the boundaries stay clear.
.squeeze_blanks <- function(txt) txt[nzchar(trimws(txt))]

# Shared session environment: snippets run in order (like a real R session)
# so later snippets can use variables/objects defined by earlier ones within
# the same chapter (e.g. lh2, Lik, t1).  Reset between chapters with new_session().
.session <- new.env(parent = globalenv())
new_session <- function() .session <<- new.env(parent = globalenv())

freeze <- function(name, seed = 1L, fig = FALSE, fig.w = 5, fig.h = 3.2,
                   width = 76, digits = 7, env = .session,
                   trim = NULL, trim.keep = 2L, drop = NULL, squeeze = FALSE) {
  #  The paths are options. The defaults are the Korean edition's; the
  #  English edition (En/build.R) swaps in its own folders. With the defaults
  #  the behavior is unchanged.
  snippet <- file.path(getOption("pmx.snipdir", "R/snippets"),
                       paste0(name, ".R"))
  outfile <- file.path(getOption("pmx.outdir",  "output"),
                       paste0(name, ".txt"))
  figfile <- file.path(getOption("pmx.figdir",  "figures"),
                       paste0(name, ".pdf"))
  stopifnot(file.exists(snippet))

  old <- options(width = width, digits = digits)
  on.exit(options(old), add = TRUE)
  set.seed(seed)

  # Figure font: the same face as the body sans (KoPubWorld Dotum). The 22
  # matplotlib figures under pyfig/ use it too, so every figure carrying
  # Korean has one face. (cairo re-embeds this font under CairoFont-* names,
  #  so the name KoPubWorld does not appear in pdffonts output -- the Korean
  #  renders correctly.)
  # Without cairo it falls back to pdf(), where Korean may break.
  # The font name below must stay as it is: it is a real font name.
  #  The family is an option so the English edition (En/build.R) can use a
  #  Latin face. The default is the Korean edition's and is unchanged.
  fam <- getOption("pmx.figfont", "KoPubWorld돋움체 Medium")
  if (fig) {
    if (capabilities("cairo")) grDevices::cairo_pdf(figfile, width = fig.w, height = fig.h, family = fam)
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
