$PROB TGI LLC, POWER LAW, V0 FIXED   P:tg100  F:BASE
$INPUT ID TIME DV MDV
$DATA ../../data/tgi-llc.csv IGNORE=@
$PRED
  V0   = 1
  A    = THETA(1) * EXP(ETA(1))
  GAM  = THETA(2)
  GM   = 1 - GAM
  F    = (V0**GM + A * GM * TIME)**(1 / GM)
  IPRE = F
  W    = SQRT(THETA(3)**2 + THETA(4)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 1)           ; A (mm3^(1-gamma)/day)
  (0, 0.7, 0.99)   ; GAMMA, exponent
  (0, 10)          ; additive error SD (mm3)
  (0, 0.2)         ; proportional error CV

$OMEGA
  0.05         ; A

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME DV MDV IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID A ETA1
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID TIME
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID MDV
     ONEHEADER NOPRINT NOAPPEND FILE=catab
