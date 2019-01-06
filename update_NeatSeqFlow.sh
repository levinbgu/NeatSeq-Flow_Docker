#!/bin/bash

# Update NeatSeq-Flow
source /opt/conda/bin/activate NeatSeq_Flow_Tutorial
pip install git+https://github.com/bioinfo-core-BGU/neatseq-flow.git
pip install git+https://github.com/bioinfo-core-BGU/neatseq-flow-modules.git
source /opt/conda/bin/deactivate


# Update NeatSeq-Flow GUI
source /opt/conda/bin/activate NeatSeq_Flow_GUI
pip install git+https://github.com/bioinfo-core-BGU/NeatSeq-Flow-GUI.git
#source deactivate