//START_TABLE sw_reg
`SWREG_W(KNN_RESET,          1, 0) //Timer soft reset
`SWREG_W(KNN_ENABLE,         1, 0) //Timer enable

//adicionado
`SWREG_BANKW(BANK_TESTP, 32, 4) //DATA_W ; M

//adicionado
`SWREG_BANKR(BANK_nb_list, 40, 4) //DATA_W ; M


`SWREG_W(DATAP_REG,			32, 0)
//`SWREG_W(TESTP,				32, 0)
`SWREG_W(LABEL_REG,			 8, 0)
`SWREG_R(OUT_REG,           32, 0)

