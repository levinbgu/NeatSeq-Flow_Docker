#!/bin/bash


YOURQ=all.q
MASTER_HOST_SLOTS=$(nproc)
HOME=/root
pgrep -x "sge_qmaster"
if ! [ -d $SGE_ROOT/$SGE_CELL ]; then
  cd $SGE_ROOT
  ./inst_sge.sh -m -x -s -auto /root/sge_auto_install.conf;
  sed -i "s/HOSTNAME/`hostname`/" $HOME/sge_exec_host.conf;
  /opt/sge/bin/lx-amd64/qconf -au sgeadmin arusers;
  /opt/sge/bin/lx-amd64/qconf -au root arusers;
  /opt/sge/bin/lx-amd64/qconf -Me $HOME/sge_exec_host.conf;
  /opt/sge/bin/lx-amd64/qconf -Aq $HOME/sge_queue.conf;
  /opt/sge/bin/lx-amd64/qconf -Ap $HOME/pe_shared.conf;
fi

flag=0
getent passwd | while IFS=: read -r name password uid gid gecos home shell; do
  if [[ $flag -eq 0 ]] ; then
    if [ $name == 'sgeadmin' ] ; then
        flag=1
    fi
  else
     echo Adding $name to the SGE submission list
    /opt/sge/bin/lx-amd64/qconf -au $name arusers;
  fi
done



# get stored SGE hostname
export SGE_HOST=`cat /opt/sge/default/common/act_qmaster`

## rename files from SGE_HOST to HOSTNAME
# find /opt/sge/ -name "*$SGE_HOST*" | sed -e "p;s/$SGE_HOST/$HOSTNAME/" | xargs -n2 mv

## replace SGE_HOST text in files
# grep -Rl "$SGE_HOST" /opt/sge/ | xargs sed -i "s/$SGE_HOST/$HOSTNAME/g"

# restart SGE
/etc/init.d/sgemaster.docker-sge restart
/etc/init.d/sgeexecd.docker-sge restart

/opt/sge/bin/lx-amd64/qconf -aattr queue slots [$SGE_HOST=$MASTER_HOST_SLOTS] $YOURQ
