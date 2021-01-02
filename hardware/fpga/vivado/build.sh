#!/usr/bin/bash
TOP_MODULE="iob_knn"
echo $PATH
export XILINXPATH=/tools/Xilinx
export LM_LICENSE_FILE=$LM_LICENSE_FILE:$XILINXPATH/Xilinx.lic
source /opt/Xilinx/Vivado/2019.2/settings64.sh
vivado -nojournal -log vivado.log -mode batch -source ../knn.tcl -tclargs "$TOP_MODULE" "$1" "$2" "$3" "$4"
