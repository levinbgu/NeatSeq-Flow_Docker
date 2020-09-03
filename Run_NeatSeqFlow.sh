#!/bin/bash

su sgeadmin -c 'cd /home/sgeadmin/ && source activate NeatSeq_Flow && NeatSeq_Flow_GUI.py --Server --PORT 49190 --UNLOCK_USER_DIR'