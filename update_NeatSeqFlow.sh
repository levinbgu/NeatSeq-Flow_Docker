#!/bin/bash

CONDA='/usr/local/bin/'
# Update NeatSeq-Flow
source $CONDA/activate NeatSeq_Flow_Tutorial
pip install --no-deps git+https://github.com/bioinfo-core-BGU/neatseq-flow.git
pip install --no-deps git+https://github.com/bioinfo-core-BGU/neatseq-flow-modules.git
source /opt/conda/bin/deactivate


# Update NeatSeq-Flow GUI
source $CONDA/activate NeatSeq_Flow_GUI
pip install --no-deps git+https://github.com/bioinfo-core-BGU/NeatSeq-Flow-GUI.git
#source deactivate

$CONDA/conda clean --all --yes