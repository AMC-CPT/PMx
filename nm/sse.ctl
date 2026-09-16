$PROB DESIGN SSE, 1COMP ORAL   P:ROOT  F:BASE
$INPUT ID TIME AMT DV MDV EVID
$DATA ../../data/_sse.csv IGNORE=@
$SUBR ADVAN2 TRANS2
$ABBR DERIV2=NO

$PK
  KA = THETA(1) * EXP(ETA(1))
  CL = THETA(2) * EXP(ETA(2))
  V  = THETA(3) * EXP(ETA(3))
  S2 = V

$ERROR
  IPRE = F
  W    = 1
  W    = SQRT(THETA(4)**2 + THETA(5)**2 * IPRE**2)
  IF (W.LT.1E-6) W = 1E-6
  IRES = DV - IPRE
  IWRE = IRES / W
  Y    = IPRE + W * EPS(1)

; start at the true values: this study asks what the design can tell, not whether
; the optimizer finds the minimum from far away (chapter 8 asked that)
$THETA
  (0, 1.2)     ; KA (1/h)
  (0, 4)       ; CL (L/h)
  (0, 50)      ; V  (L)
  (0, 0.05)    ; additive error SD (mg/L)
  (0, 0.12)    ; proportional error CV

$OMEGA
  0.16         ; KA
  0.09         ; CL
  0.04         ; V

$SIGMA 1 FIX

$EST MAX=9999 PRINT=0 METHOD=COND INTER NSIG=2 SIGL=6
     NOABORT NOTBT NOOBT NOSBT
