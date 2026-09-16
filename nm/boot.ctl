$PROB PHENO BOOTSTRAP   P:108wt  F:CL~WT,V~WT
$INPUT ID DAT2=DROP TIME AMT RATE CMT DV MDV EVID
       WT BWT SEX APGR CREA TAFD=DROP
$DATA ../../data/_boot.csv IGNORE=@
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

; Initial values are the final estimates of 108wt, so every replicate
; starts from the full-data solution. See chapter 14 for what that hides.
;
; Bounds are as wide as the model allows. A replicate that wants an
; extreme value must be free to go there. A bound that clips it makes
; the confidence interval look narrower than it is.
$THETA
  (0, 0.00731506)      ; CL (L/h)
  (0, 1.49004)         ; V  (L)
  (0, 2.07286)         ; additive error SD (mg/L)
  (0, 0.0724404)       ; proportional error CV
  (-20, 1.13332, 20)   ; WT~CL
  (-20, 0.915276, 20)  ; WT~V

$OMEGA BLOCK(2)
  0.0468821
  0.0275845  0.0209607

$SIGMA 1 FIX

; For bootstrap, drop MSFO, PRINT, $COV and $TAB (Analects 23.A).
; Hundreds of runs. Produce nothing we will not read.
$EST MAX=9999 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
