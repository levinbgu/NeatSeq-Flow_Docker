#!/bin/bash


YOURQ=all.q
MASTER_HOST_SLOTS=$(nproc)
PE=shared

# get stored SGE hostname
export SGE_HOST=`cat /opt/sge/default/common/act_qmaster`

# rename files from SGE_HOST to HOSTNAME
find /opt/sge/ -name "*$SGE_HOST*" | sed -e "p;s/$SGE_HOST/$HOSTNAME/" | xargs -n2 mv

# replace SGE_HOST text in files
grep -Rl "$SGE_HOST" /opt/sge/ | xargs sed -i "s/$SGE_HOST/$HOSTNAME/g"

# restart SGE
/etc/init.d/sgemaster.docker-sge restart
/etc/init.d/sgeexecd.docker-sge restart

/opt/sge/bin/lx-amd64/qconf -aattr queue slots [$SGE_HOST=$MASTER_HOST_SLOTS] $YOURQ
/opt/sge/bin/lx-amd64/qconf -aattr queue pe_list $PE $YOURQ

# Update NeatSeq-Flow
source /opt/conda/bin/activate NeatSeq_Flow_Tutorial
pip install git+https://github.com/bioinfo-core-BGU/neatseq-flow.git
pip install git+https://github.com/bioinfo-core-BGU/neatseq-flow-modules.git
source /opt/conda/bin/deactivate


# Update NeatSeq-Flow GUI
source /opt/conda/bin/activate NeatSeq_Flow_GUI
pip install git+https://github.com/bioinfo-core-BGU/NeatSeq-Flow-GUI.git
#source deactivate