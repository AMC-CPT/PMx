$PROB THEO 1COMP ORAL AS ODE, DUMP THE SENSITIVITIES NONMEM INTEGRATES   P:110ka  F:BASE
$INPUT ID TIME AMT RATE=DROP DV MDV EVID WT
$DATA ../../data/theo-nm.csv IGNORE=@
$SUBR ADVAN13 TOL=9
$ABBR COMRES=6 DERIV2=NO
$MODEL COMP=(DEPOT DEFDOSE) COMP=(CENT DEFOBS)

$PK
  KA = THETA(1) * EXP(ETA(1))
  CL = THETA(2) * EXP(ETA(2))
  V  = THETA(3) * EXP(ETA(3))
  KE = CL / V
  S2 = V

$DES
  DADT(1) = -KA * A(1)
  DADT(2) =  KA * A(1) - KE * A(2)

$ERROR
  ; verbatim lines are copied to Fortran as they are: no ; comments on them
"FIRST
" USE PROCM_REAL, ONLY: DAETA
  IPRE = F
  W    = SQRT(THETA(4)**2 + THETA(5)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)
  ; DAETA(i,j) = dA(i)/dETA(j): the sensitivities PREDPP integrated alongside A.
  ; G(j,1) = dY/dETA(j) at EPS=0, i.e. the G matrix of chapter 8. Both are
  ; Fortran-level quantities, so they are copied out with verbatim code.
"LAST
" COM(1) = DAETA(2,1)
" COM(2) = DAETA(2,2)
" COM(3) = DAETA(2,3)
" COM(4) = G(1,1)
" COM(5) = G(2,1)
" COM(6) = G(3,1)

$THETA
  (0, 1.5)     ; KA (1/h)
  (0, 3)       ; CL (L/h)
  (0, 30)      ; V  (L)
  (0, 0.5)     ; additive error SD (mg/L)
  (0, 0.1)     ; proportional error CV

$OMEGA
  0.4          ; KA
  0.1          ; CL
  0.05         ; V

$SIGMA 1 FIX

$EST MAX=9999 PRINT=5 METHOD=COND INTER NSIG=3 SIGL=9
     NOABORT NOTBT NOOBT NOSBT
$COV UNCOND PRINT=E
$TAB ID TIME AMT DV MDV EVID IPRE COM(1)=DA21 COM(2)=DA22 COM(3)=DA23
     COM(4)=G1 COM(5)=G2 COM(6)=G3
     ONEHEADER NOPRINT FILE=sdtab
$TAB ID KA CL V ETA1 ETA2 ETA3
     ONEHEADER NOPRINT NOAPPEND FILE=patab
$TAB ID WT
     ONEHEADER NOPRINT NOAPPEND FILE=cotab
$TAB ID EVID
     ONEHEADER NOPRINT NOAPPEND FILE=catab
