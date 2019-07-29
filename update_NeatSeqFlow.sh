#!/bin/bash

CONDA='/usr/local/bin/'
# Update NeatSeq-Flow
source $CONDA/activate NeatSeq_Flow
pip install --no-deps git+https://github.com/bioinfo-core-BGU/neatseq-flow.git
pip install --no-deps git+https://github.com/bioinfo-core-BGU/neatseq-flow-modules.git
pip install --no-deps git+https://github.com/bioinfo-core-BGU/NeatSeq-Flow-GUI.git
#source /opt/conda/bin/deactivate

#source deactivate

$CONDA/conda clean --all --yes