#!/bin/ksh

# EXPORT list here
set -x
export IOBUF_PARAMS=
export FORT_BUFFERED=TRUE
export MKL_CBWR=AVX
ulimit -s unlimited
ulimit -a

export ATP_ENABLED=0
export MALLOC_MMAP_MAX_=0
export MALLOC_TRIM_THRESHOLD_=134217728

export MPICH_ABORT_ON_ERROR=1
export MPICH_ENV_DISPLAY=1
export MPICH_VERSION_DISPLAY=1
export MPICH_CPUMASK_DISPLAY=1

export KMP_STACKSIZE=1024m
export OMP_NUM_THREADS=1
export KMP_AFFINITY=disabled

#export OMP_NUM_THREADS=1
export KMP_AFFINITY=disabled

export MP_EUIDEVICE=sn_all
export MP_EUILIB=us
export MP_SHARED_MEMORY=no
export MEMORY_AFFINITY=core:1

export NODES=20
export total_tasks=40
export OMP_NUM_THREADS=1
export taskspernode=2

export gefsmpexec_mpmd="  aprun -b -j1 -n40 -N2 -d1 -cc depth  cfp mpmd_cmdfile"

export envir=${envir:-dev}
export RUN_ENVIR=${RUN_ENVIR:-dev}

# CALL executable job script here






$SOURCEDIR/jobs/JGEFS_INIT_COMBINE

