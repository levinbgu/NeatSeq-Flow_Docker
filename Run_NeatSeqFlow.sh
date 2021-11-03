#!/bin/bash
su sgeadmin -l -c 'cd /home/sgeadmin/ && source activate NeatSeq_Flow && NeatSeq_Flow_GUI.py --Server --PORT 49190 --UNLOCK_USER_DIR'
#source activate NeatSeq_Flow

# echo 'N' | NeatSeq_Flow_GUI.py \
    # --Server \
    # --PORT 49190 \
    # --SSH_HOST localhost \
    # --UNLOCK_USER_DIR 