$PROB MAB IN MONKEY, 2COMP + QSS TMDD (KSS REPLACES KON/KOFF), FO   P:tm103  F:CL~BWT,V1~BWT,KSYN~BWT
$INPUT ID LVL SEX BWT TIME AMT DV MDV
$DATA ../../data/tmdd-mab.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$ABBR DERIV2=NO
; quasi-steady-state approximation (Gibiansky 2008): the complex is in QSS with free
; drug and free target, so KON and KOFF collapse into KSS = (KOFF + KINT)/KON.
; states are TOTALS: A(1) total drug in central (free + complex), A(3) total target.
$MODEL COMP=(CTOT DEFDOSE DEFOBS) COMP=(PERIPH) COMP=(RTOT)

$PK
  TVCL = THETA(1) * BWT
  TVV1 = THETA(2) * BWT
  CL   = TVCL * EXP(ETA(1))
  V1   = TVV1 * EXP(ETA(2))
  Q    = THETA(3)
  V2   = THETA(4) * EXP(ETA(3))
  K    = CL / V1
  K12  = Q / V1
  K21  = Q / V2

  KSS  = THETA(5)                           ; amount units (mg), like KON in tm100
  KINT = THETA(7)
  TVSY = THETA(12) * BWT
  TVDE = THETA(9)
  KSYN = TVSY * EXP(ETA(4))
  KDEG = TVDE * EXP(ETA(5))
  BASE = KSYN / KDEG
  A_0(3) = BASE

$DES
  ; free drug from the totals: the positive root of the QSS quadratic
  A1F  = 0.5 * ((A(1) - A(3) - KSS) + SQRT((A(1) - A(3) - KSS)**2 + 4 * KSS * A(1)))
  A4   = A(1) - A1F                         ; complex
  A3F  = A(3) - A4                          ; free target
  DADT(1) = -(K + K12) * A1F + K21 * A(2) - KINT * A4
  DADT(2) = K12 * A1F - K21 * A(2)
  DADT(3) = KSYN - KDEG * A3F - KINT * A4

$ERROR
  A1FE = 0.5 * ((A(1) - A(3) - KSS) + SQRT((A(1) - A(3) - KSS)**2 + 4 * KSS * A(1)))
  IPRE = A1FE / V1                          ; free drug concentration
  RO   = (A(1) - A1FE) / A(3)
  RTOT = A(3)
  W    = SQRT(THETA(10)**2 + THETA(11)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (1E-5, 0.0002, 0.003)   ; CL per kg
  (1E-3, 0.032, 0.3)      ; V1 per kg
  (1E-4, 0.003, 0.04)     ; Q
  (1E-3, 0.014, 0.2)      ; V2
  (1E-4, 0.05, 5)         ; KSS (mg)
  0 FIX                   ; (KOFF has no place in the QSS model; kept so THETA numbers match tm100)
  (1E-3, 0.013, 0.2)      ; KINT
  0 FIX                   ; KSYN intercept, dropped as in tm103
  (1E-3, 0.15, 50)        ; KDEG (upper bound widened: the first run sat on 2)
  (1E-8, 0.015, 20)       ; additive error SD
  (1E-3, 0.07, 0.2)       ; proportional error CV
  (1E-3, 0.018, 2)        ; KSYN slope on BWT

$OMEGA BLOCK(3)
  0.2
  -0.01 0.02
  -0.3 0.19 5.6
$OMEGA BLOCK(2)
  0.1
  0.2 0.8

$SIGMA 1 FIX

$EST MAX=9999 PRINT=10 METHOD=ZERO POSTHOC NSIG=2 SIGL=6
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME LVL DV MDV IPRE IWRE CWRES RO RTOT
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V1 Q V2 KSS KINT KSYN KDEG BASE ETA1 ETA2 ETA3 ETA4 ETA5
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID BWT LVL
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID SEX
     ONEHEADER NOPRINT NOAPPEND FILE=catab
