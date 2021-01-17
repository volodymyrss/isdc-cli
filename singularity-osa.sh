#!/bin/bash

#SBATCH --job-name test
#SBATCH --partition shared-cpu
#
#SBATCH --ntasks 1
#SBATCH --time=00:15:00

cmd=$@

echo -e "\033[31msingularity-osa with command: \"$@\"\033[0m"

cd $(realpath $PWD)

source $HOME/.bash_profile
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

echo "REP_BASE_PROD: $REP_BASE_PROD"
echo "DATA_ROOT: $DATA_ROOT"

singularity exec \
        -B /srv:/srv \
        -B $DATA_ROOT/:/data \
        -B $REP_BASE_PROD/cat:$PWD/cat \
        -B $REP_BASE_PROD/scw:$PWD/scw \
        -B $REP_BASE_PROD/aux:$PWD/aux \
        -B $REP_BASE_PROD/ic:$PWD/ic \
        -B $REP_BASE_PROD/idx:$PWD/idx \
        -B $REP_BASE_PROD/cat:/isdc/arc/rev_3/cat \
        -B $REP_BASE_PROD/scw:/isdc/arc/rev_3/scw \
        -B $REP_BASE_PROD/aux:/isdc/arc/rev_3/aux \
        -B $REP_BASE_PROD/ic:/isdc/arc/rev_3/ic \
        -B $REP_BASE_PROD/idx:/isdc/arc/rev_3/idx \
        $IMAGE \
        bash -c "source $HOME/.bash_profile
                 export HOME_OVERRRIDE=$HOME 
                 echo -n loading\ env... 
                 source /init${init_suffix}.sh 
                 echo done 
                 export REP_BASE_PROD_CONS=/isdc/arc/rev_3 
                 export INTEGRAL_DATA=/isdc/arc/rev_3
                 export CURRENT_IC=/isdc/arc/rev_3
                 strace -e open -f $cmd"

#
