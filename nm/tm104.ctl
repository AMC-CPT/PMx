$PROB MAB IN MONKEY, 2COMP + MICHAELIS-MENTEN ELIMINATION (TMDD LIMIT), FO   P:tm103  F:CL~BWT,V1~BWT
$INPUT ID LVL SEX BWT TIME AMT DV MDV
$DATA ../../data/tmdd-mab.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$ABBR DERIV2=NO
; the crudest reduction of TMDD: binding, target turnover and internalization all
; fast, so the target-mediated loss looks like a saturable elimination VM*C/(KM + C).
$MODEL COMP=(CENTRAL DEFDOSE DEFOBS) COMP=(PERIPH)

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
  VM   = THETA(5) * BWT * EXP(ETA(4))         ; mg/h, scales with size like KSYN did
  KM   = THETA(6)                             ; mg/L

$DES
  C1 = A(1) / V1
  DADT(1) = -(K + K12) * A(1) + K21 * A(2) - VM * C1 / (KM + C1)
  DADT(2) = K12 * A(1) - K21 * A(2)

$ERROR
  IPRE = A(1) / V1
  W    = SQRT(THETA(7)**2 + THETA(8)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (1E-5, 0.0002, 0.003)   ; CL per kg
  (1E-3, 0.032, 0.3)      ; V1 per kg
  (1E-4, 0.003, 0.04)     ; Q
  (1E-3, 0.014, 0.2)      ; V2
  (1E-4, 0.002, 1)        ; VM per kg (mg/h/kg)
  (1E-4, 0.1, 100)        ; KM (mg/L)
  (1E-8, 0.015, 20)       ; additive error SD
  (1E-3, 0.07, 0.2)       ; proportional error CV

$OMEGA BLOCK(3)
  0.2
  -0.01 0.02
  -0.3 0.19 5.6
$OMEGA 0.2

$SIGMA 1 FIX

$EST MAX=9999 PRINT=10 METHOD=ZERO POSTHOC NSIG=2 SIGL=6
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME LVL DV MDV IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V1 Q V2 VM KM ETA1 ETA2 ETA3 ETA4
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID BWT LVL
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID SEX
     ONEHEADER NOPRINT NOAPPEND FILE=catab
