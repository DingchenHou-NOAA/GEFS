#!/bin/ksh
#

# EXPORT list here
set -x

ulimit -s unlimited
ulimit -a

#export OMP_NUM_THREADS=${GEFS_TPP:-2}

# CALL executable job script here
$SOURCEDIR/jobs/JGEFS_EXTRACTVARS
