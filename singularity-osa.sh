#!/bin/bash

#SBATCH --job-name test
#SBATCH --partition shared-cpu
#
#SBATCH --ntasks 1
#SBATCH --time=00:15:00

cmd=$@

echo -e "\033[31msingularity-osa with command: \"$@\"\033[0m"

cd $(realpath $PWD)

source $HOME/env/init.sh

IMAGE=$SHARED_SCRATCH/singularity/integral-pack-0.1.sif

module load GCCcore/8.2.0 Singularity/3.4.0-Go-1.12

export DISPLAY=""

echo -e "\033[32mwill use OSA version ${osa_version:=11.0}\033[0m"

if [ ${osa_version} == "10.2" ]; then
	export init_suffix="-osa10.2";
elif [ ${osa_version} == "11.0" ]; then
	export init_suffix="";
fi


set -x

singularity exec \
        -B /srv:/srv \
        -B $SHARED_SCRATCH/data/scw:$PWD/scw \
        -B $SHARED_SCRATCH/data/aux:$PWD/aux \
        -B $SHARED_SCRATCH/data/ic:$PWD/ic \
        -B $SHARED_SCRATCH/data/idx:$PWD/idx \
        -B $SHARED_SCRATCH/data/cat:/isdc/arc/rev_3/cat \
        -B $SHARED_SCRATCH/data/scw:/isdc/arc/rev_3/scw \
        -B $SHARED_SCRATCH/data/aux:/isdc/arc/rev_3/aux \
        -B $SHARED_SCRATCH/data/ic:/isdc/arc/rev_3/ic\
        $IMAGE \
        bash -c "export HOME_OVERRRIDE=$HOME; source /init${init_suffix}.sh; $cmd"

set +x

#
