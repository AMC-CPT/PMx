$PROB PHENO 1COMP IV BOLUS SIM   P:108wt  F:CL~WT,V~WT
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

; Final estimates of 108wt, fixed as truth. Nothing is estimated here.
$THETA
  0.00731506 FIX   ; CL (L/h)
  1.49004    FIX   ; V  (L)
  2.07286    FIX   ; additive error SD (mg/L)
  0.0724404  FIX   ; proportional error CV
  1.13332    FIX   ; WT~CL
  0.915276   FIX   ; WT~V

$OMEGA BLOCK(2) FIX
  0.0468821
  0.0275845  0.0209607

$SIGMA 1 FIX

; Simulate 200 times without re-estimation. ONLYSIM skips estimation.
$SIM (20260915) ONLYSIMULATION SUBPROBLEMS=200

$TAB ID TIME DV MDV
     ONEHEADER NOPRINT NOAPPEND FILE=simtab
