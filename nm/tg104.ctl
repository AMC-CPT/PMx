$PROB TGI LLC, VON BERTALANFFY (WBE) ODE, V0 FIXED   P:tg100  F:BASE
$INPUT ID TIME DV MDV EVID
$DATA ../../data/tgi-llc-ode.csv IGNORE=@
$SUBR ADVAN13 TOL=8
$MODEL
  COMP = (TUMOR)
$PK
  V0   = 1
  AG   = THETA(1) * EXP(ETA(1))
  GAM  = THETA(2)
  B    = THETA(3) * EXP(ETA(2))
  A_0(1) = V0
  S1   = 1

$DES
  DADT(1) = AG * A(1)**GAM - B * A(1)

$ERROR
  IPRE = F
  W    = SQRT(THETA(4)**2 + THETA(5)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 1.5)         ; AG, anabolic rate
  (0, 0.75, 0.99)  ; GAMMA (2/3 in von Bertalanffy, 3/4 in WBE)
  (0, 0.3)         ; B, catabolic rate (1/day)
  (0, 10)          ; additive error SD (mm3)
  (0, 0.2)         ; proportional error CV

$OMEGA
  0.05         ; AG
  0.05         ; B

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME DV MDV EVID IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID AG B ETA1 ETA2
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID TIME
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID MDV
     ONEHEADER NOPRINT NOAPPEND FILE=catab
