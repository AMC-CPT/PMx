# =====================================================================
#  En/build.R  -  regenerate the English edition's frozen R output
#
#  Run from the repository root:   Rscript En/build.R
#
#  It reuses the Korean edition's machinery (R/_freeze.R) but redirects
#  the three paths:
#      snippets  R/snippets/      ->  En/R/snippets/     (translated)
#      output    output/          ->  En/output/         (regenerated)
#      figures   figures/         ->  En/figures-check/  (thrown away)
#
#  Figures are NOT regenerated for the English edition: none of the 49
#  figures contains Korean, so the book reuses ../figures/.  Anything a
#  snippet draws here goes to a scratch folder so that an English build
#  can never overwrite the Korean edition's frozen figures.
#
#  Like R/build.R this does NOT call NONMEM.  It reads the run artifacts
#  committed under nm/, so it runs on a machine without a license.
# =====================================================================
if (!dir.exists("R/snippets"))
  stop("Run from the repository root (where R/snippets/ lives).")

dir.create("En/output",  showWarnings = FALSE, recursive = TRUE)
dir.create("En/figures", showWarnings = FALSE, recursive = TRUE)

#  45 of the 49 figures carry Korean (axis labels, legends), so the English
#  edition regenerates them from the translated snippets, with a Latin face.
#  Any figure whose snippet is not yet translated is seeded from the Korean
#  edition so that the book always finds one; En/check.py reports how many of
#  those still carry Korean.
for (f in list.files("figures", "\\.pdf$")) {
  dst <- file.path("En/figures", f)
  if (!file.exists(dst)) file.copy(file.path("figures", f), dst)
}

options(pmx.snipdir = "En/R/snippets",
        pmx.outdir  = "En/output",
        pmx.figdir  = "En/figures",
        pmx.figfont = "Arial")

source("R/_freeze.R")

have_nm <- function(...) {
  f <- file.path("nm", c(...))
  ok <- all(file.exists(f))
  if (!ok) message(sprintf("  skipped: %s missing. Rscript R/runnm.R (license needed)",
                           paste(basename(f[!file.exists(f)]), collapse = ", ")))
  ok
}

#  Only the chapters that have been translated so far.  Add a block each
#  time a chapter's snippets are translated, mirroring R/build.R.
have <- function(name) file.exists(file.path("En/R/snippets",
                                             paste0(name, ".R")))

message("Freezing English R output ...")

## ---- Ch 2: Installing NONMEM and Taming Its Output --------------------
if (have("ch02-cc") && have_nm("100base.R76/100base.lst")) {
  new_session()
  freeze("ch02-cc")
  freeze("ch02-trim")
  freeze("ch02-need")
}

## ---- Ch 3: Working Environment and Reproducibility --------------------
if (have("ch03-rng")) {
  new_session()
  freeze("ch03-rng")
  freeze("ch03-hash")
  if (have_nm("oq1.R76/oq1.ext")) freeze("ch03-oq", digits = 6)
}

## ---- Ch 5: Data Assembly ----------------------------------------------
#  Assemble seven SDTM-style domains into one NONMEM dataset, as one session.
#  NOTE: ch05-check writes data/pheno-nm.csv, which is SHARED with the Korean
#  edition. The logic is identical, so the bytes must come out identical; the
#  English build is verified against that.
if (have("ch05-read")) {
  new_session()
  freeze("ch05-read")
  freeze("ch05-dm")
  freeze("ch05-ex")
  freeze("ch05-pctime")
  freeze("ch05-pc")
  freeze("ch05-vs")
  freeze("ch05-lb")
  freeze("ch05-build")
  freeze("ch05-cov")
  freeze("ch05-final")
  freeze("ch05-check")
}

## ---- Ch 6: Data Checking and Verification -----------------------------
if (have("ch06-read")) {
  new_session()
  freeze("ch06-theo-dose", digits = 4)
  freeze("ch06-theofig", fig = TRUE, fig.w = 5.2, fig.h = 2.4)
  freeze("ch06-theo-fix",  digits = 4)
  freeze("ch06-read")
  freeze("ch06-time")
  freeze("ch06-sametime")
  freeze("ch06-order")
  freeze("ch06-assert")
  freeze("ch06-mustfail")
  freeze("ch06-sexcode")
  freeze("ch06-blq")
  if (have_nm("120base.R76/120base.ext", "120m1.R76/120m1.ext",
              "120m3.R76/120m3.ext", "120m5.R76/120m5.ext"))
    freeze("ch06-blqfit", digits = 3)
  freeze("ch06-tiny")
}

## ---- Ch 7: The Base Model ---------------------------------------------
if (have("ch07-time") &&
    have_nm("100base.R76/100base.ext", "101diag.R76/101diag.ext",
            "100base.R76/sdtab")) {
  new_session()
  freeze("ch07-time")
  freeze("ch07-fit")
  freeze("ch07-omega")
  freeze("ch07-lrt")
  freeze("ch07-gof",   fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  freeze("ch07-resid", fig = TRUE, fig.w = 6.4, fig.h = 3.2)
}
if (have("ch07-theo") &&
    have_nm("110ka.R76/110ka.ext", "111lag.R76/111lag.ext", "112zo.R76/112zo.ext",
            "113blk.R76/113blk.ext", "110ka.R76/sdtab")) {
  new_session()
  freeze("ch07-theo")
  freeze("ch07-abs")
  freeze("ch07-absfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
  if (file.exists("nm/110kax.R76/110kax.ext")) freeze("ch07-flip")
  freeze("ch07-blk")
}
if (have("ch07-mult") &&
    have_nm("130mult.R76/130mult.ext", "130addl.R76/130addl.ext",
            "130ss.R76/130ss.ext", "130ssx.R76/130ssx.ext",
            "130addl.R76/sdtab", "130addl.R76/patab")) {
  new_session()
  freeze("ch07-mult")
  freeze("ch07-multfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  freeze("ch07-multx")
}
if (have("ch07-cpt") &&
    have_nm("140iv2.R76/140iv2.ext", "200iv2.R76/200iv2.ext",
            "300iv2.R76/300iv2.ext", "140iv2.R76/sdtab", "200iv2.R76/sdtab")) {
  new_session()
  freeze("ch07-cpt", digits = 3)
  freeze("ch07-cptfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
}

## ---- Ch 8: Estimation Methods and Convergence -------------------------
if (have("ch08-sigdig") &&
    have_nm("100base.R76/100base.cor", "102sig.R76/102sig.cor",
            "103mats.R76/103mats.cor", "104matr.R76/104matr.cor",
            "105start.R76/105start.cor")) {
  new_session()
  freeze("ch08-sigdig")
  freeze("ch08-cond")
  freeze("ch08-block")
  freeze("ch08-move")
  freeze("ch08-counter")
  freeze("ch08-iterfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
  if (have_nm("110ka.R76/110ka.ext", "110ka.R76/patab"))
    freeze("ch08-expfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
}
if (have("ch08-em") &&
    have_nm("100foce.R76/100foce.ext", "100its.R76/100its.ext",
            "100imp.R76/100imp.ext", "100saem.R76/100saem.ext",
            "100bayes.R76/100bayes.ext")) {
  new_session()
  freeze("ch08-em")
}
if (have("ch08-daeta") && have_nm("110des.R76/sdtab", "110des.R76/patab")) {
  new_session()
  freeze("ch08-daeta")
}

## ---- Ch 9: Covariate Search -------------------------------------------
if (have("ch09-ebe") &&
    have_nm("100base.R76/patab", "106wtcl.R76/106wtcl.ext",
            "107wtv.R76/107wtv.ext", "108wt.R76/108wt.ext",
            "109sex.R76/109sex.ext", "108wt.R76/patab")) {
  new_session()
  freeze("ch09-ebe")
  freeze("ch09-ebefig", fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  freeze("ch09-forward")
  freeze("ch09-cutoff")
  freeze("ch09-omega")
  freeze("ch09-after",  fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  freeze("ch09-sex")
  if (have_nm("108wtbwt.R76/108wtbwt.ext", "108wtbwt.R76/108wtbwt.cor"))
    freeze("ch09-collin", digits = 3)                 # collinearity (defines se())
  if (have_nm("108full.R76/108full.ext"))
    freeze("ch09-full", digits = 3)                   # full model (uses se() from ch09-collin)
}

## ---- Ch 10: Judgment in Covariate Selection ---------------------------
if (have("ch10-ci") &&
    have_nm("108wt.R76/108wt.ext", "108wts.R76/108wts.ext",
            "108wtx.R76/108wtx.ext", "108wtcr.R76/108wtcr.ext")) {
  new_session()
  freeze("ch10-ci")
  freeze("ch10-fix")
  freeze("ch10-effect")
  freeze("ch10-forest", fig = TRUE, fig.w = 5.6, fig.h = 2.6)
  freeze("ch10-shrink")
  freeze("ch10-eta")
}

## ---- Ch 11: Reading the Diagnostics -----------------------------------
#  nmw's eight reports. They read only committed artifacts, so they are
#  produced without NONMEM. The PDFs are gitignored (remade at any time).
if (have("ch11-reports") &&
    have_nm("108wt.R76/sdtab", "108wt.R76/PRINT.OUT", "108wt.R76/FCON")) {
  new_session()
  freeze("ch11-reports")
  freeze("ch11-s1")
  freeze("ch11-sa")
  freeze("ch11-shrink")
  freeze("ch11-etafig", fig = TRUE, fig.w = 6.6, fig.h = 2.2)
  if (file.exists("nm/108wt.R76/108wt.phi")) {
    freeze("ch11-phi")
    freeze("ch11-phifig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  }
  if (file.exists("nm/108wtsim.R76/simtab.csv")) {
    freeze("ch11-refplot", fig = TRUE, fig.w = 6.4, fig.h = 3.2)
    freeze("ch11-refstat")
  }
  suppressWarnings(freeze("ch11-sumout"))   # warns that SumOut cannot summarize the simulation-only 108wtsim (no estimation); does not affect the frozen output
}

## ---- Ch 12: Simulation-Based Diagnostics ------------------------------
if (have("ch12-vpc") && have_nm("108wtsim.R76/simtab.csv", "108wt.R76/sdtab")) {
  new_session()
  freeze("ch12-vpc")
  freeze("ch12-vpcfig",   fig = TRUE, fig.w = 6.4, fig.h = 3.6)
  freeze("ch12-pcvpc")
  freeze("ch12-pcvpcfig", fig = TRUE, fig.w = 6.4, fig.h = 3.6)
  freeze("ch12-npc")
  freeze("ch12-pd",       fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  if (requireNamespace("npde", quietly = TRUE))                     # Ch 12 NPDE (npde package)
    freeze("ch12-npde",   fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  freeze("ch12-stratfig", fig = TRUE, fig.w = 6.4, fig.h = 3.2)
}

## ---- Ch 13: Randomization Tests ---------------------------------------
#  The merge/match example needs no NONMEM. The null distribution is read
#  from nm/rpt/rpt.csv, produced by R/rpt.R (one small file).
if (have("ch13-merge")) {
  new_session()
  freeze("ch13-merge")
  freeze("ch13-assert")
  if (file.exists("nm/rpt/rpt.csv") && have_nm("100base.R76/100base.ext",
                                               "108wt.R76/108wt.ext")) {
    freeze("ch13-null")
    freeze("ch13-nullfig", fig = TRUE, fig.w = 6.4, fig.h = 3.4)
    freeze("ch13-quant")
    freeze("ch13-fcut")
    freeze("ch13-tail")
    freeze("ch13-wald")
  }
}

## ---- Ch 14: Parameter Uncertainty -------------------------------------
#  The asymptotic SE comes straight from the committed 108wt.ext. The
#  resampling and the profile read the small csv files made by R/boot.R
#  and R/llp.R. One session throughout (later snippets all use fin/se/key from ch14-asym).
if (have("ch14-asym") && have_nm("108wt.R76/108wt.ext")) {
  new_session()
  freeze("ch14-asym")
  freeze("ch14-strat")
  if (file.exists("nm/boot/boot.csv")) {
    freeze("ch14-boot")
    freeze("ch14-bootfig", fig = TRUE, fig.w = 6.6, fig.h = 2.5)
    freeze("ch14-bootdiag")
  }
  if (file.exists("nm/llp/llp.csv")) {
    freeze("ch14-llp")
    freeze("ch14-llpfig", fig = TRUE, fig.w = 6.6, fig.h = 2.5)
    freeze("ch14-li")
  }
  if (file.exists("nm/sir/sir.csv"))
    freeze("ch14-sir")
  if (all(file.exists("nm/boot/boot.csv", "nm/llp/llp.csv", "nm/sir/sir.csv")))
    freeze("ch14-compare")
}

## ---- Ch 16: The Structure of Variability ------------------------------
#  Reads simulated data with known true values (R/mkdata/make_iov.R) and the run artifacts of nm/120*-124*.
if (have("ch16-data")) {
  new_session()
  freeze("ch16-data")
  freeze("ch16-occfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
  if (have_nm("120base.R76/120base.ext", "120add.R76/120add.ext", "120prop.R76/120prop.ext",
              "121iov.R76/121iov.ext", "122mix.R76/122mix.ext", "123mixiov.R76/123mixiov.ext",
              "124etaeps.R76/124etaeps.ext", "121iov.R76/sdtab", "123mixiov.R76/catab")) {
    freeze("ch16-resid")
    freeze("ch16-residfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
    freeze("ch16-iov")
    freeze("ch16-iovfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
    freeze("ch16-etafig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
    freeze("ch16-mix")
    freeze("ch16-etaeps")
    freeze("ch16-ladder")
  }
}

## ---- Ch 17: Population Analysis of PD and PK/PD -----------------------
#  Reads simulated data with known true values (R/mkdata/make_pd.R) and the run artifacts of nm/pd*.
if (have("ch17-data")) {
  new_session()
  freeze("ch17-data")
  freeze("ch17-tcfig", fig = TRUE, fig.w = 6.0, fig.h = 3.2)
  if (have_nm("pd100.R76/pd100.ext", "pd100x.R76/pd100x.ext", "pd101.R76/pd101.ext",
              "pd101b.R76/pd101b.ext",
              "pd102.R76/pd102.ext", "pd103.R76/pd103.ext", "pd200ord.R76/pd200ord.ext")) {
    freeze("ch17-fit")
    freeze("ch17-natural")
    freeze("ch17-noplacebo")
    freeze("ch17-baseline")
    freeze("ch17-errfig", fig = TRUE, fig.w = 6.4, fig.h = 3.2)
    if (file.exists("nm/pd100sim.R76/simtab.csv"))
      freeze("ch17-vpcfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
    freeze("ch17-ord")
  }
}

## ---- Ch 18: Population Analysis of Indirect Response Models -----------
#  Reads simulated data with known true values (R/mkdata/make_warf.R) and the run artifacts of nm/wf*.
#  wf200 reads data/warf-ipp.csv, which is built from the patab of wf100.
if (have("ch18-data")) {
  new_session()
  freeze("ch18-data")
  freeze("ch18-tcfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
  if (have_nm("wf100.R76/wf100.ext", "wf200.R76/wf200.ext", "wf201.R76/wf201.ext",
              "wf202.R76/wf202.ext", "wf203.R76/wf203.ext", "wf201.R76/sdtab",
              "wf202.R76/sdtab", "wf203.R76/sdtab")) {
    freeze("ch18-pk")
    freeze("ch18-ipp")
    freeze("ch18-sim")
    freeze("ch18-fitfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
    freeze("ch18-wrong")
    freeze("ch18-wrongfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
    if (file.exists("nm/wf201sim.R76/simtab.csv"))
      freeze("ch18-vpc", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  }
}

## ---- Ch 18 (second example): TMDD -------------------------------------
#  Reads practice data (monkey data with the development code removed) and the artifacts of nm/tm100-tm104.
if (have("ch18-tmdd-data")) {
  new_session()
  freeze("ch18-tmdd-data")
  freeze("ch18-tmdd-fig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  if (have_nm("tm100.R76/tm100.ext", "tm101.R76/tm101.ext", "tm102.R76/tm102.ext",
              "tm103.R76/tm103.ext", "tm104.R76/tm104.ext")) {
    freeze("ch18-tmdd-fit")
    freeze("ch18-tmdd-gof", fig = TRUE, fig.w = 6.4, fig.h = 4.2)
    freeze("ch18-tmdd-foce")
    freeze("ch18-tmdd-qss")
    freeze("ch18-tmdd-ro", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  }
}

## ---- Ch 19: Tumor Growth and TGI --------------------------------------
#  Reads the results of fitting the public Benzekry data with six growth models (nm/tg*).
if (have("ch19-data")) {
  new_session()
  freeze("ch19-data")
  freeze("ch19-growfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  if (have_nm("tg100.R76/tg100.ext", "tg101.R76/tg101.ext", "tg102.R76/tg102.ext",
              "tg102b.R76/tg102b.ext", "tg103.R76/tg103.ext", "tg104.R76/tg104.ext",
              "tg105.R76/tg105.ext")) {
    freeze("ch19-compare")
    freeze("ch19-fit")
    freeze("ch19-etafig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
    freeze("ch19-indfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
    if (file.exists("nm/tg102bsim.R76/simtab.csv"))
      freeze("ch19-vpc", fig = TRUE, fig.w = 6.0, fig.h = 3.2)
    if (have_nm("tg106.R76/tg106.ext", "tg107.R76/tg107.ext")) {
      freeze("ch19-trt")
      freeze("ch19-trtfig", fig = TRUE, fig.w = 6.0, fig.h = 3.2)
    }
  }
}

## ---- Ch 20: Time-to-Event and Count Data ------------------------------
#  Reads two simulated datasets with known true values (R/mkdata/make_tte.R) and the artifacts of nm/tte* and nm/cnt*.
if (have("ch20-data")) {
  new_session()
  freeze("ch20-data")
  freeze("ch20-kmfig", fig = TRUE, fig.w = 5.6, fig.h = 3.2)
  if (have_nm("tte100.R76/tte100.ext", "tte101.R76/tte101.ext", "tte102.R76/tte102.ext")) {
    freeze("ch20-fit")
    freeze("ch20-hazfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
    freeze("ch20-kmvpc", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
  }
  freeze("ch20-cnt")
  if (have_nm("cnt100.R76/cnt100.ext", "cnt101.R76/cnt101.ext", "cnt102.R76/cnt102.ext")) {
    freeze("ch20-cntfit")
    freeze("ch20-cntfig", fig = TRUE, fig.w = 5.6, fig.h = 3.2)
  }
}

## ---- Ch 21: Pediatric Extrapolation and Prior Information -------------
#  Reads simulated data with known true values (R/mkdata/make_ped.R) and the run artifacts of nm/ped*.
if (have("ch21-data")) {
  new_session()
  freeze("ch21-data")
  if (have_nm("ped100.R76/ped100.ext", "ped101.R76/ped101.ext", "ped102.R76/ped102.ext",
              "ped101.R76/patab", "ped100.R76/patab")) {
    freeze("ch21-matfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
    freeze("ch21-fit")
    freeze("ch21-etafig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  }
  if (have_nm("ped103x.R76/ped103x.ext", "ped103.R76/ped103.ext", "ped104.R76/ped104.ext"))
    freeze("ch21-prior")
  freeze("ch21-extrap")
}

## ---- Ch 22: Study Design ----------------------------------------------
#  The information matrix is computed in R alone. Reads nm/sse/sse.csv, the result of the simulation-estimation (R/sse.R).
if (have("ch22-fim")) {
  new_session()
  freeze("ch22-fim")
  freeze("ch22-dopt")
  if (file.exists("nm/sse/sse.csv")) {
    freeze("ch22-sse")
    freeze("ch22-ssefig", fig = TRUE, fig.w = 6.6, fig.h = 2.6)
  }
}

## ---- Ch 23: Simulation, Reporting and Submission ----------------------
#  Reads only the final model's estimates and the resampling results. Runs without NONMEM.
if (have("ch23-sim") && have_nm("108wt.R76/108wt.ext")) {
  new_session()
  freeze("ch23-sim")
  freeze("ch23-simfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
  if (file.exists("nm/boot/boot.csv"))
    freeze("ch23-unc")
  freeze("ch23-power")
  freeze("ch23-manifest")
  if (file.exists("nm/boot/boot.csv") && file.exists("nm/llp/llp.csv"))
    freeze("ch23-partab")
}

message("done.")
