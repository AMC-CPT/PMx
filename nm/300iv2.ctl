$PROB IV2 DATA, 3COMP IV BOLUS (OVERPARAMETERIZED)   P:200iv2  F:BASE
$INPUT ID TIME AMT DV MDV EVID WT SEX
$DATA ../../data/iv2-sim.csv IGNORE=@
$SUBR ADVAN11 TRANS4
$ABBR DERIV2=NO

$PK
  CL = THETA(1) * EXP(ETA(1))
  V1 = THETA(2) * EXP(ETA(2))
  Q2 = THETA(3) * EXP(ETA(3))
  V2 = THETA(4) * EXP(ETA(4))
  Q3 = THETA(5) * EXP(ETA(5))
  V3 = THETA(6) * EXP(ETA(6))
  S1 = V1

$ERROR
  IPRE = F
  W    = 1
  W    = SQRT(THETA(7)**2 + THETA(8)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 5)       ; CL (L/h)
  (0, 20)      ; V1 (L)
  (0, 8)       ; Q2 (L/h)
  (0, 60)      ; V2 (L)
  (0, 1)       ; Q3 (L/h)
  (0, 100)     ; V3 (L)
  (0, 0.02)    ; additive error SD (mg/L)
  (0, 0.1)     ; proportional error CV

$OMEGA
  0.1          ; CL
  0.1          ; V1
  0.1          ; Q2
  0.1          ; V2
  0.1          ; Q3
  0.1          ; V3

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT DV MDV EVID CL V1 Q2 V2 Q3 V3 IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V1 Q2 V2 Q3 V3 ETA1 ETA2 ETA3 ETA4 ETA5 ETA6
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID WT
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID SEX
     ONEHEADER NOPRINT NOAPPEND FILE=catab
