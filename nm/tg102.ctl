$PROB TGI LLC, GOMPERTZ, V0 FIXED   P:tg100  F:BASE
$INPUT ID TIME DV MDV
$DATA ../../data/tgi-llc.csv IGNORE=@
$PRED
  V0   = 1
  ALPH = THETA(1) * EXP(ETA(1))
  BETA = THETA(2) * EXP(ETA(2))
  F    = V0 * EXP(ALPH / BETA * (1 - EXP(-BETA * TIME)))
  IPRE = F
  W    = SQRT(THETA(3)**2 + THETA(4)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 1)       ; ALPHA, initial growth rate (1/day)
  (0, 0.1)     ; BETA, decay of growth rate (1/day)
  (0, 10)      ; additive error SD (mm3)
  (0, 0.2)     ; proportional error CV

$OMEGA
  0.05         ; ALPHA
  0.05         ; BETA

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME DV MDV IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID ALPH BETA ETA1 ETA2
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID TIME
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID MDV
     ONEHEADER NOPRINT NOAPPEND FILE=catab
