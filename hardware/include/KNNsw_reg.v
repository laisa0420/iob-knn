//START_TABLE sw_reg
`SWREG_W(KNN_RESET,          1, 0) //Timer soft reset
`SWREG_W(KNN_ENABLE,         1, 0) //Timer enable
`SWREG_W(TEST_POINT,32, 0)
`SWREG_W(DATA_POINT,32, 0)
`SWREG_R(DIST,32, 0)

