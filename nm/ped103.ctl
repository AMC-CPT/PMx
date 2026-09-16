$PROB PEDIATRIC 1COMP IV, NEONATES 30 ONLY, PRIOR FROM ped104 (NWPRI)   P:ped103x  F:CL~WT+PMA,V~WT
$INPUT ID TIME AMT DV MDV EVID WT PMA AGE GRP
$DATA ../../data/ped-neo.csv IGNORE=@
$SUBR ADVAN1 TRANS2
$ABBR DERIV2=NO

$PK
  SZCL = (WT / 70) ** 0.75
  SZV  = (WT / 70) ** 1
  TM50 = THETA(5)                          ; PMA (weeks) at half maturation
  HILL = 3.4
  MAT  = PMA ** HILL / (TM50 ** HILL + PMA ** HILL)
  CL = THETA(1) * SZCL * MAT * EXP(ETA(1))
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
  (0, 50)      ; TM50 (weeks PMA)

$OMEGA
  0.1          ; CL
  0.05         ; V

$SIGMA 1 FIX

; Prior from the 90 older subjects (ped104): THETA normal with variance = SE**2,
; OMEGA inverse Wishart with 90 degrees of freedom (the number of subjects behind it).
$PRIOR NWPRI
$THETAP  (5.73 FIX) (41.0 FIX) (0.140 FIX) (0.104 FIX) (51.3 FIX)
$THETAPV BLOCK(5) FIX
  0.0563
  0 0.982
  0 0 0.000180
  0 0 0 0.0000415
  0 0 0 0 32.7
$OMEGAP BLOCK(1) 0.0801 FIX
$OMEGAP BLOCK(1) 0.0449 FIX
$OMEGAPD (90 FIX) (90 FIX)

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT DV MDV EVID IPRE IWRE CWRES
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID CL V ETA1 ETA2 MAT
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID WT PMA AGE
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID GRP
     ONEHEADER NOPRINT NOAPPEND FILE=catab
