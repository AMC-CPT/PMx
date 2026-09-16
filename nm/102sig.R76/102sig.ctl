$PROB PHENO 1COMP IV BOLUS   P:100base  F:BASE
$INPUT ID DAT2=DROP TIME AMT RATE CMT DV MDV EVID
       WT BWT SEX APGR CREA TAFD=DROP
$DATA ../../data/pheno-nm.csv IGNORE=@
$SUBR ADVAN1 TRANS2
$ABBR DERIV2=NO

$PK
  TVCL = THETA(1)
  TVV  = THETA(2)
  CL   = TVCL * EXP(ETA(1))
  V    = TVV  * EXP(ETA(2))
  S1   = V

; Same residual distribution as 100base, stored in SIGMA instead of THETA.
; 100base : Y = F + sqrt(a^2 + b^2 F^2) * EPS(1)   a,b in THETA
; here    : Y = F + EPS(1) + F * EPS(2)            a^2,b^2 in SIGMA
$ERROR
  IPRE = F
  Y    = IPRE + EPS(1) + IPRE * EPS(2)

$THETA
  (0, 0.0075)  ; CL (L/h)
  (0, 1.5)     ; V  (L)

$OMEGA BLOCK(2)
  0.3
  0.05  0.3

$SIGMA
  0.36         ; additive variance   (SD 0.6)
  0.0144       ; proportional variance (CV 0.12)

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
