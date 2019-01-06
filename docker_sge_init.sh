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
/opt/sge/bin/lx-amd64/qconf -ap $PE
/opt/sge/bin/lx-amd64/qconf -aattr queue pe_list $PE $YOURQ
