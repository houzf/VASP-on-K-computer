#!/bin/bash -x
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=8"
#PJM --mpi "proc=64"
#PJM --rsc-list "elapse=24:00:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
##---- Please set up the relative path of executable binary file of VASP 
## ----    with respect to the location path of job submission.
#PJM --stgin "rank=*../../../bin/vasp535_std   %r:./"
#PJM --stgin-dir "./  ./"
#PJM --stgout "rank=* %r:./*   ./"
#PJM -j
#PJM -S
#PJM -s
#PJM -X 
#PJM -m e,s
#PJM --mail-list "xxx@gmail.com"
#PJM --name 'test'


# Environment setting
. /work/system/Env_base



#--- Program section: 1 --------------------------------------------------
unset OMP_NUM_THREADS
PARALLEL=64; export PARALLEL

export LD_LIBRARY_PATH="/opt/FJSVtclang/GM-1.2.0-22/lib64:$LD_LIBRARY_PATH"

mpiexec -n 64  ./vasp535_std
