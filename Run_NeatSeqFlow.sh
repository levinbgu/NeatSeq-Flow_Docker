#!/bin/bash
# su sgeadmin -l -c 'cd /home/sgeadmin/ &&
# wget https://raw.githubusercontent.com/bioinfo-core-BGU/NeatSeq-Flow-Using-Docker/master/doc/Tutorial_Parameter_file.yaml &&
# wget https://raw.githubusercontent.com/bioinfo-core-BGU/neatseq-flow-tutorial/master/Samples_conda.nsfs &&
# source activate NeatSeq_Flow && NeatSeq_Flow_GUI.py --Server --PORT 49190 --UNLOCK_USER_DIR'
mkdir /home/sgeadmin/Tutorial
cd /home/sgeadmin/Tutorial
wget https://raw.githubusercontent.com/bioinfo-core-BGU/NeatSeq-Flow-Using-Docker/master/doc/Tutorial_Parameter_file.yaml &&
wget https://raw.githubusercontent.com/bioinfo-core-BGU/neatseq-flow-tutorial/master/Samples_conda.nsfs &&

source activate NeatSeq_Flow

echo 'N' | NeatSeq_Flow_GUI.py \
    --Server \
    --PORT 49190 \
    --SSH_HOST localhost \
    --UNLOCK_USER_DIR 