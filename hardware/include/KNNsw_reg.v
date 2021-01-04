//START_TABLE sw_reg
`SWREG_W(KNN_RESET,          1, 0) //Timer soft reset
`SWREG_W(KNN_ENABLE,         1, 0) //Timer enable
`SWREG_W(KNN_START,         1, 0) //start knn


`SWREG_W(DATAP_REG,			32, 0)
//`SWREG_W(TESTP,				32, 0)
`SWREG_W(LABEL_REG,			 8, 0)
`SWREG_R(OUT_REG,           32, 0)

//adicionado
`SWREG_BANKR(BANK_nb_list, 160,0, 4) //DATA_W ; M
//adicionado
`SWREG_BANKW(BANK_TESTP, 32,0, 4) //DATA_W ; M