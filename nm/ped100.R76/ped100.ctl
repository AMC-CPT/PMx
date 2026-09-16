$PROB PEDIATRIC 1COMP IV, ALLOMETRY FIXED (0.75, 1), NO MATURATION   P:ROOT  F:CL~WT,V~WT
$INPUT ID TIME AMT DV MDV EVID WT PMA AGE GRP
$DATA ../../data/ped-sim.csv IGNORE=@
$SUBR ADVAN1 TRANS2
$ABBR DERIV2=NO

$PK
  SZCL = (WT / 70) ** 0.75                ; theory-based size scaling
  SZV  = (WT / 70) ** 1
  CL = THETA(1) * SZCL * EXP(ETA(1))
  V  = THETA(2) * SZV  * EXP(ETA(2))
  S1 = V

$ERROR
  IPRE = F
  W    = 1
  W    = SQRT(THETA(3)**2 + THETA(4)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

$THETA
  (0, 5)       ; CLSTD, CL of a 70-kg mature subject (L/h)
  (0, 40)      ; VSTD  (L)
  (0, 0.2)     ; additive error SD (mg/L)
  (0, 0.1)     ; proportional error CV

$OMEGA
  0.1          ; CL
  0.05         ; V

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT DV MDV EVID IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V ETA1 ETA2
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID WT PMA AGE
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID GRP
     ONEHEADER NOPRINT NOAPPEND FILE=catab
