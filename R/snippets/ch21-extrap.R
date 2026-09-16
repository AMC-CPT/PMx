# 외삽이 뜻하는 것. 성인 70 kg 의 청소율 6 L/h 를 세 아이에게 내려보낸다.
# 체중만으로(mg/kg 그대로, 그리고 0.75 지수)와 성숙까지 넣어서. 같은 노출(AUC)을 주는
# mg/kg 용량은 청소율에 비례한다.
kids <- data.frame(누구 = c("미숙아 (28주)", "만삭 신생아 (40주)", "2세 (144주)", "10세 (562주)"),
                   WT = c(1.0, 3.4, 12, 32), PMA = c(28, 40, 144, 562))
mat <- function(pma) pma^3.4 / (55^3.4 + pma^3.4)
kids$CL_kg선형   <- round(6 * kids$WT / 70, 3)
kids$CL_지수0.75 <- round(6 * (kids$WT / 70)^0.75, 3)
kids$CL_성숙     <- round(6 * (kids$WT / 70)^0.75 * mat(kids$PMA), 3)
adult_mgkg <- 5
kids$용량_mgkg <- round(adult_mgkg * kids$CL_성숙 / kids$WT / (6 / 70), 2)
kids
