#!/bin/ksh

# EXPORT list here
set -x

#export IOBUF_PARAMS=cfi*:size=64M:count=4:verbose
#export FORT_BUFFERED=TRUE
#export MKL_CBWR=AVX
ulimit -s unlimited
ulimit -a

#export ATP_ENABLED=0
#export MALLOC_MMAP_MAX_=0
#export MALLOC_TRIM_THRESHOLD_=134217728
#
#export MPICH_ABORT_ON_ERROR=1
#export MPICH_ENV_DISPLAY=1
#export MPICH_VERSION_DISPLAY=1
#export MPICH_CPUMASK_DISPLAY=1
#
#export KMP_STACKSIZE=1024m
#export KMP_AFFINITY=disabled

#export MP_EUIDEVICE=sn_all
#export MP_EUILIB=us
#export MP_SHARED_MEMORY=no
#export MEMORY_AFFINITY=core:4

#export total_tasks=6
#export OMP_NUM_THREADS=4
#export taskspernode=6

#export FORECAST_SEGMENT=hr

# export for development runs only begin
#export envir=${envir:-dev}
#export RUN_ENVIR=${RUN_ENVIR:-dev}

#export gefsmpexec_mpmd="aprun -b -j1 -n${total_tasks} -N${taskspernode} -d${OMP_NUM_THREADS} -cc depth cfp mpmd_cmdfile"

# CALL executable job script here
. $SOURCEDIR/jobs/JGEFS_ATMOS_ENSSTAT
