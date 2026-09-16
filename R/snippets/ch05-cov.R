# 시불변으로 쓰기로 한 기저 체중은 값 하나를 전 레코드에 퍼뜨리는 것으로 끝난다.
nm$WT <- vsb$BWT[match(nm$SUBJID, vsb$SUBJID)]

# 같은 체중을 시변으로도 만들어 둔다. 빈칸은 LOCF 로 채운다.
nm <- merge_cov_locf(nm, vsw, value_cols = "BWT",  time_col = "VSDTC",
                     median_fb = FALSE)
nm <- merge_cov_locf(nm, lbc, value_cols = "CREA", time_col = "LBDTC",
                     median_fb = FALSE)
stopifnot(!anyNA(nm$WT), !anyNA(nm$BWT), !anyNA(nm$CREA))   # 빈칸이 남으면 안 된다

# 두 선택이 얼마나 다른가. 자료가 정해 주지 않는다. 사람이 고르고 사전에 적는다.
table(체중 = ifelse(nm$BWT == nm$WT, "기저와 같음", "기저와 다름"))
c(기저대비최대 = round(max(nm$BWT / nm$WT), 3))
