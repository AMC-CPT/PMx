$PROB PHENO LLP   P:108wt  F:CL~WT,V~WT
$INPUT ID DAT2=DROP TIME AMT RATE CMT DV MDV EVID
       WT BWT SEX APGR CREA TAFD=DROP
$DATA ../../data/pheno-nm.csv IGNORE=@
$SUBR ADVAN1 TRANS2
$ABBR DERIV2=NO

$PK
  TVCL = THETA(1) * (WT/1.5)**THETA(5)
  TVV  = THETA(2) * (WT/1.5)**THETA(6)
  CL   = TVCL * EXP(ETA(1))
  V    = TVV  * EXP(ETA(2))
  S1   = V

$ERROR
  IPRE = F
  W    = 1
  W    = SQRT(THETA(3)**2 + THETA(4)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  Y    = IPRE + W * EPS(1)

; This is a TEMPLATE, not a runnable model as it stands.
; R/llp.R rewrites exactly one marked line into "<value> FIX" and writes
; the result to nm/_llp.ctl. Control files whose name starts with an
; underscore are generated; R/runnm.R skips them.
;
; The data are the full data set. Only one parameter is held fixed;
; everything else is re-estimated at each grid point. That is what makes
; this a PROFILE likelihood rather than a slice through the surface.
$THETA
  (0, 0.00731506)      ; CL (L/h)
  (0, 1.49004)         ; V  (L)
  (0, 2.07286)         ; additive error SD (mg/L)  <T3>
  (0, 0.0724404)       ; proportional error CV
  (-20, 1.13332, 20)   ; WT~CL  <T5>
  (-20, 0.915276, 20)  ; WT~V   <T6>

$OMEGA BLOCK(2)
  0.0468821
  0.0275845  0.0209607

$SIGMA 1 FIX

$EST MAX=9999 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
