$PROB PHENO 1COMP IV BOLUS   P:108wt  F:CL~WT(FIX0.75),V~WT(FIX1)
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
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 0.0075)  ; CL (L/h)
  (0, 1.5)     ; V  (L)
  (0, 0.6)     ; additive error SD (mg/L)
  (0, 0.12)    ; proportional error CV
  0.75 FIX     ; WT~CL (allometric 0.75)
  1 FIX        ; WT~V

$OMEGA BLOCK(2)
  0.3
  0.05  0.3

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
