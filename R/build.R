# =====================================================================
#  R/build.R  -  frozen R output 과 그림을 다시 만든다
#  저장소 최상위에서 실행:   Rscript R/build.R
#  장을 쓸 때마다 freeze(...) 한 줄씩 늘린다.
# =====================================================================
if (!file.exists("PMx.tex"))
  stop("저장소 최상위에서 실행하라 (PMx.tex 가 있는 곳).")

dir.create("output",  showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
source("R/_freeze.R")

# 이 스크립트는 **NONMEM 을 부르지 않는다.** nm/ 에 커밋된 실행 산출물을 읽을
# 뿐이므로 라이선스가 없는 PC 에서도 돈다. 산출물이 없으면 그 장을 건너뛰고
# 무엇을 돌려야 하는지 알린다. 만들려면: Rscript R/runnm.R (라이선스 필요)
have_nm <- function(...) {
  f <- file.path("nm", c(...))
  ok <- all(file.exists(f))
  if (!ok) message(sprintf("  건너뜀: %s 가 없다. Rscript R/runnm.R (라이선스 필요)",
                           paste(basename(f[!file.exists(f)]), collapse = ", ")))
  ok
}

message("Freezing R output/figures ...")

## ---- 2장: NONMEM 설치와 출력 다듬기 ------------------------------------
#  커밋된 .lst 를 읽어 제어문자를 보이고 TrimOut 으로 다듬는다.
if (have_nm("100base.R76/100base.lst")) {
  new_session()
  freeze("ch02-cc")
  freeze("ch02-trim")
  freeze("ch02-need")
}

## ---- 3장: 작업 환경과 재현성 -------------------------------------------
new_session()
freeze("ch03-rng")
freeze("ch03-hash")
if (have_nm("oq1.R76/oq1.ext")) freeze("ch03-oq", digits = 6)   # OQ 실례 (벤더 예제)

## ---- 5장: 자료 준비 ----------------------------------------------------
#  SDTM 형 도메인 일곱을 NONMEM 데이터셋 하나로 조립한다. 한 세션으로 이어지며
#  마지막 ch05-check 의 stopifnot 이 곧 이 장의 시험이다(깨지면 빌드가 선다).
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

## ---- 6장: 자료 점검과 검증 -------------------------------------------
#  문을 여는 THEO 용량 오기 대조에 이어, 5장이 만든 데이터셋을 점검한다.
#  ch06-assert 가 정의한 check_nm() 을 ch06-mustfail 이 다시 쓴다(같은 세션).
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
if (have_nm("120base.R76/120base.ext", "120m1.R76/120m1.ext", "120m3.R76/120m3.ext",
            "120m5.R76/120m5.ext")) freeze("ch06-blqfit", digits = 3)
freeze("ch06-tiny")

## ---- 7장: 기저 모형 ----------------------------------------------------
#  NONMEM 실행 산출물이 있어야 얼릴 수 있다. 없으면 건너뛴다.
if (have_nm("100base.R76/100base.ext", "101diag.R76/101diag.ext",
            "100base.R76/sdtab")) {
  new_session()
  freeze("ch07-time")
  freeze("ch07-fit")
  freeze("ch07-omega")
  freeze("ch07-lrt")
  freeze("ch07-gof",   fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  freeze("ch07-resid", fig = TRUE, fig.w = 6.4, fig.h = 3.2)
}
#  두 번째 예제: theophylline 경구 흡수 (nm/110ka, 111lag, 112zo, 113blk)
if (have_nm("110ka.R76/110ka.ext", "111lag.R76/111lag.ext", "112zo.R76/112zo.ext",
            "113blk.R76/113blk.ext", "110ka.R76/sdtab")) {
  new_session()
  freeze("ch07-theo")
  freeze("ch07-abs")
  freeze("ch07-absfig", fig = TRUE, fig.w = 6.6, fig.h = 2.4)
  if (file.exists("nm/110kax.R76/110kax.ext"))
    freeze("ch07-flip")
  freeze("ch07-blk")
}
#  세 번째 예제: 반복 투여 (nm/130mult, 130addl, 130ss, 130ssx)
if (have_nm("130mult.R76/130mult.ext", "130addl.R76/130addl.ext", "130ss.R76/130ss.ext",
            "130ssx.R76/130ssx.ext", "130addl.R76/sdtab", "130addl.R76/patab")) {
  new_session()
  freeze("ch07-mult")
  freeze("ch07-multfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
  freeze("ch07-multx")
}
#  네 번째 예제: 구획의 수 (nm/140iv2, 200iv2, 300iv2; 자료 R/mkdata/make_iv2.R)
if (have_nm("140iv2.R76/140iv2.ext", "200iv2.R76/200iv2.ext", "300iv2.R76/300iv2.ext",
            "140iv2.R76/sdtab", "200iv2.R76/sdtab")) {
  new_session()
  freeze("ch07-cpt", digits = 3)
  freeze("ch07-cptfig", fig = TRUE, fig.w = 6.4, fig.h = 3.0)
}

## ---- 8장: 추정 방법과 수렴 --------------------------------------------
if (have_nm("100base.R76/100base.cor", "102sig.R76/102sig.cor",
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
#  추정 방법 비교 (nm/100foce, 100its, 100imp, 100saem, 100bayes)
if (have_nm("100foce.R76/100foce.ext", "100its.R76/100its.ext", "100imp.R76/100imp.ext",
            "100saem.R76/100saem.ext", "100bayes.R76/100bayes.ext")) {
  new_session()
  freeze("ch08-em")
}
#  $DES 의 민감도: NONMEM 이 적분한 DAETA 와 R 의 적분을 맞춘다 (nm/110des)
if (have_nm("110des.R76/sdtab", "110des.R76/patab")) {
  new_session()
  freeze("ch08-daeta")
}

## ---- 9장: 공변량 탐색 --------------------------------------------------
if (have_nm("100base.R76/patab", "106wtcl.R76/106wtcl.ext",
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
    freeze("ch09-collin", digits = 3)                 # 다중공선성 (se() 를 정의한다)
  if (have_nm("108full.R76/108full.ext"))
    freeze("ch09-full", digits = 3)                   # 완전 모형 (ch09-collin 의 se() 를 쓴다)
}

## ---- 10장: 공변량 선택의 판단 ------------------------------------------
if (have_nm("108wt.R76/108wt.ext", "108wts.R76/108wts.ext",
            "108wtx.R76/108wtx.ext", "108wtcr.R76/108wtcr.ext")) {
  new_session()
  freeze("ch10-ci")
  freeze("ch10-fix")
  freeze("ch10-effect")
  freeze("ch10-forest", fig = TRUE, fig.w = 5.6, fig.h = 2.6)
  freeze("ch10-shrink")
  freeze("ch10-eta")
}

## ---- 11장: 진단 판독 ----------------------------------------------------
#  nmw 의 보고 8종. 커밋된 산출물만 읽으므로 NONMEM 이 없어도 만들어진다.
#  만들어진 PDF 는 .gitignore 대상이다(언제든 다시 만들어진다).
if (have_nm("108wt.R76/sdtab", "108wt.R76/PRINT.OUT", "108wt.R76/FCON")) {
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
  suppressWarnings(freeze("ch11-sumout"))   # SumOut 이 모의 전용 108wtsim(추정 없음)을 요약하지 못한다는 경고. 언 출력과 무관하다
}

## ---- 12장: 모의 기반 진단 ----------------------------------------------
if (have_nm("108wtsim.R76/simtab.csv", "108wt.R76/sdtab")) {
  new_session()
  freeze("ch12-vpc")
  freeze("ch12-vpcfig",   fig = TRUE, fig.w = 6.4, fig.h = 3.6)
  freeze("ch12-pcvpc")
  freeze("ch12-pcvpcfig", fig = TRUE, fig.w = 6.4, fig.h = 3.6)
  freeze("ch12-npc")
  freeze("ch12-pd",       fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  if (requireNamespace("npde", quietly = TRUE))                     # 12장 NPDE (npde 패키지)
    freeze("ch12-npde",   fig = TRUE, fig.w = 6.4, fig.h = 3.2)
  freeze("ch12-stratfig", fig = TRUE, fig.w = 6.4, fig.h = 3.2)
}

## ---- 13장: 무작위 순열 검정 --------------------------------------------
#  merge/match 예제는 NONMEM 이 필요 없다. 귀무분포는 R/rpt.R 이 만든
#  nm/rpt/rpt.csv 를 읽는다(작은 파일 하나).
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

## ---- 14장: 파라미터 불확실성 -------------------------------------------
#  점근 SE 는 커밋된 108wt.ext 에서 바로 나온다. 재표집과 프로파일은
#  R/boot.R, R/llp.R 이 만든 작은 csv 를 읽는다. 한 세션으로 이어진다
#  (ch14-asym 의 fin/se/key 를 뒤의 스니펫이 전부 쓴다).
new_session()
if (have_nm("108wt.R76/108wt.ext")) {
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

## ---- 16장: 변동성의 구조 -------------------------------------------------
#  참값을 아는 모의 자료(R/mkdata/make_iov.R)와 nm/120*-124* 의 실행 산출물을 읽는다.
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

## ---- 17장: PD 와 PK/PD 의 집단 분석 -----------------------------------
#  참값을 아는 모의 자료(R/mkdata/make_pd.R)와 nm/pd* 의 실행 산출물을 읽는다.
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

## ---- 18장: 간접반응 모형의 집단 분석 -------------------------------------
#  참값을 아는 모의 자료(R/mkdata/make_warf.R)와 nm/wf* 의 실행 산출물을 읽는다.
#  wf200 은 data/warf-ipp.csv 를 읽고, 그 파일은 wf100 의 patab 에서 만든다.
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

## ---- 18장 (둘째 예제): TMDD ---------------------------------------------
#  실무 자료(개발 코드를 지운 원숭이 자료)와 nm/tm100-tm104 의 산출물을 읽는다.
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

## ---- 19장: 종양성장과 TGI --------------------------------------------
#  Benzekry 공개 자료를 여섯 성장 모형으로 적합한 결과(nm/tg*)를 읽는다.
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

## ---- 20장: 시간-사건과 카운트 자료 ---------------------------------------
#  참값을 아는 모의 자료 둘(R/mkdata/make_tte.R)과 nm/tte*, nm/cnt* 의 산출물을 읽는다.
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

## ---- 21장: 소아 외삽과 사전 정보 -----------------------------------------
#  참값을 아는 모의 자료(R/mkdata/make_ped.R)와 nm/ped* 의 실행 산출물을 읽는다.
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

## ---- 22장: 시험 설계 -----------------------------------------------------
#  정보행렬은 R 만으로 계산한다. 모의-추정(R/sse.R)의 결과 nm/sse/sse.csv 를 읽는다.
new_session()
freeze("ch22-fim")
freeze("ch22-dopt")
if (file.exists("nm/sse/sse.csv")) {
  freeze("ch22-sse")
  freeze("ch22-ssefig", fig = TRUE, fig.w = 6.6, fig.h = 2.6)
}

## ---- 23장: 시뮬레이션, 보고, 제출 --------------------------------------
#  최종 모형의 추정치와 재표집 결과만 읽는다. NONMEM 이 없어도 돈다.
if (have_nm("108wt.R76/108wt.ext")) {
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
