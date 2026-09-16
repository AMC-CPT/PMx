$PROB TGI TREATED, GOMPERTZ, NO TREATMENT EFFECT   P:tg102b  F:BASE
$INPUT ID TIME DV MDV GRP
$DATA ../../data/tgi-trt.csv IGNORE=@
$PRED
  V0   = 1
  ALPH = THETA(1) * EXP(ETA(1))
  BETA = THETA(2) * EXP(ETA(2))
  TST  = 7                                  ; treatment starts at day 7
  ALPT = ALPH                             ; no effect: same rate after day 7
  ; before treatment start every animal follows the control curve
  V7   = V0 * EXP(ALPH / BETA * (1 - EXP(-BETA * TST)))
  F    = V0 * EXP(ALPH / BETA * (1 - EXP(-BETA * TIME)))
  IF (TIME.GT.TST) F = V7 * EXP(ALPT / BETA * (EXP(-BETA * TST) - EXP(-BETA * TIME)))
  IPRE = F
  W    = SQRT(THETA(3)**2 + THETA(4)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 0.75)    ; ALPHA (1/day)
  (0, 0.08)    ; BETA (1/day)
  (0, 30)      ; additive error SD (mm3)
  (0, 0.1)     ; proportional error CV

$OMEGA BLOCK(2)
  0.03
  0.04  0.06

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=ERS
$TAB ID TIME DV MDV GRP IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID ALPH BETA ETA1 ETA2
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID TIME
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID GRP
     ONEHEADER NOPRINT NOAPPEND FILE=catab
