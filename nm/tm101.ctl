$PROB MAB IN MONKEY, 2COMP + FULL TMDD, FOCE-I FROM THE FO SOLUTION   P:tm100  F:CL~BWT,V1~BWT,KSYN~BWT
$INPUT ID LVL SEX BWT TIME AMT DV MDV
$DATA ../../data/tmdd-mab.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$ABBR DERIV2=NO
$MODEL COMP=(CENTRAL DEFDOSE DEFOBS) COMP=(PERIPH) COMP=(TARGET) COMP=(COMPLEX)

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
  S1   = V1

  KON  = THETA(5)
  KOFF = THETA(6)
  KINT = THETA(7)
  TVSY = THETA(8) + THETA(12) * BWT
  TVDE = THETA(9)
  KSYN = TVSY * EXP(ETA(4))
  KDEG = TVDE * EXP(ETA(5))
  BASE = KSYN / KDEG
  A_0(3) = BASE

$DES
  DADT(1) = -(K + K12) * A(1) + K21 * A(2) - KON * A(1) * A(3) + KOFF * A(4)
  DADT(2) = K12 * A(1) - K21 * A(2)
  DADT(3) = KSYN - KDEG * A(3) - KON * A(1) * A(3) + KOFF * A(4)
  DADT(4) = KON * A(1) * A(3) - (KOFF + KINT) * A(4)

$ERROR
  IPRE = F
  RO   = A(4) / (A(3) + A(4))
  RTOT = A(3) + A(4)
  W    = SQRT(THETA(10)**2 + THETA(11)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

; initial estimates: the FO solution of tm100 (rounded)
$THETA
  (1E-5, 0.00025, 0.003)  ; CL per kg
  (1E-3, 0.032, 0.3)      ; V1 per kg
  (1E-4, 0.0028, 0.04)    ; Q
  (1E-3, 0.013, 0.2)      ; V2
  (1E-2, 0.3, 4)          ; KON
  (1E-4, 0.0019, 0.03)    ; KOFF
  (1E-3, 0.014, 0.2)      ; KINT
  (1E-4, 0.001, 0.6)      ; KSYN intercept
  (1E-3, 0.14, 2)         ; KDEG
  (1E-8, 0.013, 20)       ; additive error SD
  (1E-3, 0.07, 0.2)       ; proportional error CV
  (1E-3, 0.017, 2)        ; KSYN slope on BWT

$OMEGA BLOCK(3)
  0.19
  -0.007 0.02
  -0.3 0.2 6.3
$OMEGA BLOCK(2)
  0.1
  0.21 0.8

$SIGMA 1 FIX

$EST MAX=9999 PRINT=10 METHOD=COND INTER NSIG=2 SIGL=6
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME LVL DV MDV IPRE IWRE CWRES RO RTOT
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V1 Q V2 KON KOFF KINT KSYN KDEG BASE ETA1 ETA2 ETA3 ETA4 ETA5
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID BWT LVL
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID SEX
     ONEHEADER NOPRINT NOAPPEND FILE=catab
