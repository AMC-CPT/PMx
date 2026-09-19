# 예제 자료

이 책의 예제는 **공개 자료와 이 책이 만든 모의 자료**만 쓴다.
실제 과제의 자료는 워크플로와 실패 사례의 출처일 뿐 본문에도 이 저장소에도 싣지 않는다.
18장 둘째 예제의 원숭이 자료만은 책에서는 실무 자료(개발 코드를 지운 것)를 썼고,
이 저장소의 `tmdd-mab.csv` 는 그 최종 모형으로 같은 설계를 모의한 대역이다
(`R/mkdata/sim_tmdd.R`, seed 2026). 그래서 `nm/tm10?.ctl` 을 다시 돌리면 책의 숫자와
비슷하되 같지는 않고, `nm/tm10?.R76/` 실행 산출물도 여기 없다.

## `pheno.csv` - 정답 데이터셋

phenobarbital 신생아 자료. **NONMEM 배포 예제**(Beal & Sheiner)이며,
원본은 고정폭 파일 `PHENO` 다(마지막 줄의 `FIN` 은 NONMEM 의 끝 표지).

| | |
|---|---|
| 행 | 744 (투약 589, 관측 155) |
| 대상자 | 59 |
| 열 | `ID TIME AMT WT APGR DV MDV EVID` |
| 특징 | `WT` 와 `APGR` 은 대상자 내 상수. 대상자당 투약 중앙값 12회 |

## `theo-raw.txt` - 6장의 용량 오기 대조

NONMEM 배포본 `util/THEO` 의 사본(132행, 12명). 열은 `ID DOSE TIME CP WT` 이고
`DOSE` 는 mg/kg 이다.

시험 설계는 **전원 theophylline 320 mg 경구 투여**다. 체중을 곱해 되돌리면
11명은 318.6-320.6 mg 인데 **9번만 267.8 mg**(3.10 × 86.4)으로 52 mg 이 빈다.
$320/86.4 = 3.7037$ 이므로 적혀야 할 값은 3.70 이고, 3.7 로 고치면 319.68 mg 이다.

미국식으로 쓴 7 은 1 과 모양이 거의 같아(한국식 7 에는 왼쪽 위 획이 하나 더 있다)
손글씨를 옮겨 적으며 생긴 오류로 보인다. **같은 오류가 R 내장 `Theoph` 에도 있다.**

6장이 이것으로 문을 연다. 재현은 `R/snippets/ch06-theo-dose.R`,
`R/snippets/ch06-theo-fix.R` 이고 고정 출력은 `output/` 에 있다.

## `sdtm/` - 5장 실습용 원천 도메인

> **이 도메인들은 이 책이 만든 가공물이다.** 실제 임상시험 자료가 아니다.
> 위 `pheno.csv` 를 **거꾸로 분해해서** 만들었다.

5장은 흩어진 도메인을 합쳐 가는 과정을 가르치는데, 공개 자료는 이미 합쳐진
NONMEM 데이터셋뿐이다. 분해해 두면 다시 합쳤을 때 **정답을 이미 알고 있으므로**
독자가 자기 파이프라인이 옳은지 스스로 검증할 수 있다. 이 책의 "참값을 아는
자료로 시험한다"는 방침과 같다.

| 파일 | 행 | 내용 |
|---|---|---|
| `dm.csv` | 59 | 인구학. **체중이 여기 없다**(5장의 첫 강조점) |
| `ex.csv` | 589 | 투약 기록 |
| `pc.csv` | 214 | 농도. **계획시각**으로 기록. 투여 전 0 레코드 59건 포함 |
| `pc_coll.csv` | 214 | **실채혈시각**(참값). 계획시각은 30분 눈금이라 최대 12분 어긋난다 |
| `vs.txt` | 146 | 체중. **탭 구분**. 방문마다 측정되어 시변 |
| `lb.csv` | 118 | 크레아티닌. **검열값이 문자열**(`"<0.2"`, `"<17.7"`) |
| `lb_norm.csv` | 3 | **기관별 정상상한**. 기관 03 은 단위가 다르다 |

### 의도적으로 심은 문제 여섯

5장이 가르칠 것을 자료 안에 미리 넣어 두었다.

1. **체중이 DM 이 아니라 VS 에 있다.** 그리고 방문마다 측정되어 시변이다.
   기저값(DAY 1)이 `pheno.csv` 의 `WT` 와 같으므로, 시불변으로 다루기로 하면
   정답과 맞고 시변으로 다루면 달라진다. 두 선택의 차이를 눈으로 볼 수 있다
2. **계획시각과 실채혈시각이 다르다.** `pc.csv` 는 30분 눈금의 계획시각이고
   실제는 `pc_coll.csv` 에 있다. 계획시각으로 적합하면 편향이 생긴다.
   **실채혈시각이 원자료의 참값이다.** 그것으로 조립하면 `pheno.csv` 와 정확히
   일치하고, 계획시각으로 조립하면 관측 155건 중 63건이 최대 12분 어긋난다
3. **검열값이 문자열이다.** `LBORRES` 에 `"<0.2"` 가 들어 있어 `as.numeric()`
   하면 `NA` 가 된다
4. **기관별 정상상한과 단위가 다르다.** 기관 01/02 는 mg/dL(상한 0.50, 0.60),
   기관 03 은 umol/L(상한 53.0). `lb_norm.csv` 를 `SITEID` 로 붙이지 않으면
   신기능 공변량이 기관 효과를 재게 된다
5. **투여 전 0 레코드가 있다.** 외인성 약물이므로 선험적으로 0 이다.
   NCA 면 반드시 넣고 NONMEM 이면 `MDV=1` 로 두거나 뺀다. BLQ 비율 계산에서도
   분자·분모 모두 제외한다(`PCREASND == "PREDOSE"` 로 식별)
6. **파일 형식이 제각각이다.** `vs.txt` 만 탭 구분이고 나머지는 쉼표다

### 재현

```sh
Rscript R/mkdata/make_sdtm.R
```

`set.seed(20260914)`, `RNGkind()` 는 `"Mersenne-Twister" "Inversion" "Rejection"`.
생성기는 원본 `PHENO` 파일이 필요하다(`make_sdtm.R` 의 `SRC` 경로).
**생성 결과는 저장소에 커밋되어 있으므로 다시 돌리지 않아도 된다.**

### 출처 표기

본문에서 이 자료를 쓸 때 다음을 밝힌다.

> phenobarbital 신생아 자료(Beal SL, Sheiner LB. NONMEM 배포 예제).
> 5장의 SDTM 형 도메인은 이 자료를 분해하여 이 책이 만든 것이다.

## `pheno-nm.csv` - 5장이 조립한 결과

위 `sdtm/` 을 5장의 파이프라인으로 다시 합친 것이다. **손으로 만들지 않는다.**
`R/snippets/ch05-check.R` 의 마지막 줄이 쓰며, 그 직전의 `stopifnot()` 을
통과한 것만 나온다. 따라서 이 파일은 `Rscript R/build.R` 의 부산물이다.

| | |
|---|---|
| 행 | 803 (투약 589, 관측 155, **투여 전 채혈 59**) |
| 열 | `ID TIME AMT RATE CMT DV MDV EVID WT BWT SEX APGR CREA DAT2 CLOCK` |
| 정답 대조 | 투여 전 59행을 빼면 `pheno.csv` 744행과 전부 일치한다 |

`pheno.csv` 와 다른 점은 셋이다. (i) 투여 전 채혈 59행이 `MDV=1` 로 남아 있다,
(ii) 공변량 `BWT`(시변 체중), `SEX`, `CREA` 가 더 있다, (iii) 벽시계 시각
`DAT2`/`CLOCK` 이 추적용으로 남아 있다. **`SEX` 는 대상자 번호의 홀짝으로
배정한 가짜 공변량**이므로 공변량 탐색의 예로 쓰면 안 된다.

6장이 이 파일을 입력으로 받아 점검한다(`R/snippets/ch06-*.R`).

## 모의 자료 (참값을 안다)

| 파일 | 만드는 스크립트 | 내용 | 장 |
|---|---|---|---|
| `pd-sim.csv` `pd-ord.csv` | `R/mkdata/make_pd.R` | 통증 NRS, 위약 포함 네 군 160명 | 17 |
| `iov-sim.csv` | `R/mkdata/make_iov.R` | 세 회차 경구, 60명. IOV 와 청소율 아집단(POP 열이 참값) | 16 |
| `warf-sim.csv` `warf-ipp.csv` | `R/mkdata/make_warf.R`, `make_warf_ipp.R` | warfarin 형 PK/PD 40명. IPP 용은 `wf100` 의 EBE 를 열로 | 18 |
| `tmdd-mab.csv` | `R/mkdata/sim_tmdd.R` (모의 대역, seed 2026) | 단클론항체 원숭이 50마리, 여섯 용량. 책의 원자료와 같은 설계 | 18 |
| `tgi-*.csv` | `R/mkdata/make_tgi.R`, `make_tgi_trt.R` | 종양 부피 (공개 자료를 다시 정리) 와 치료군 모의 | 19 |
| `tte-sim.csv` `cnt-sim.csv` | `R/mkdata/make_tte.R` | 시간-사건 300명, 발작 횟수 200명 | 20 |
| `ped-sim.csv` `ped-neo.csv` `ped-old.csv` | `R/mkdata/make_ped.R` | 소아 120명과 그 부분 자료 | 21 |
| `theo-nm.csv` | `R/mkdata/make_theo.R` | THEO 를 NONMEM 데이터셋으로 | 7, 8 |
| `mult-explicit.csv` `mult-addl.csv` `mult-ss.csv` `mult-ssx.csv` | `R/mkdata/make_mult.R` | 반복 경구 투여 30명을 세 가지로 코딩한 것과 함정 | 7 |

`*-truth.csv` 가 각 자료의 참값이다. 모든 스크립트에 seed 가 박혀 있다.

## 2026-09-19 추가 (증보 4건의 자료)

| 파일 | 만드는 스크립트 | 내용 | 장 |
|---|---|---|---|
| `iov-blq.csv` | `R/mkdata/make_blq.R` | `iov-sim.csv` 의 관측을 LLOQ 0.5 mg/L 에서 자른 것. `BLQ` 열이 1 인 행의 `DV` 는 LLOQ/2. 관측 1,260 중 BLQ 164(13.0 %) | 6 |
| `iv2-sim.csv` `iv2-sim-truth.csv` | `R/mkdata/make_iv2.R` | 2구획 정맥 bolus 40명, 11회 채혈. `WT`·`SEX` 는 표를 채우는 가짜 공변량 | 7 |
| `example1.csv` | (NONMEM 7.6 배포본 `examples/`) | 벤더 OQ 예제 `setest.ctl` 의 자료. 제3자 저작물, 공개 저장소 제외 | 3 |
