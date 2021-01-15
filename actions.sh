#!/bin/bash

cmd=${@}

module load GCC/4.9.3-2.25 OpenMPI/1.10.2 jq/1.5

function echo_red() {
    echo -e "\e[31m$@\e[0m"
}


function scwlist() {
    n=${1:-1}
    mkdir -pv work

    scwlist=work/scwlist.txt
    curl 'https://www.astro.unige.ch/cdci/astrooda/dispatch-data/gw/timesystem/api/v1.0/scwlist/cons/2018-03-15T00:00:00/2019-03-15T00:00:00?&ra=83&dec=22&radius=6.0&min_good_isgri=1000' \
            | jq -r '.[]' | shuf -n ${n} > $scwlist
    echo "got $(wc -l < $scwlist) scw(s):"
    echo "..."
    tail -n 10 $scwlist
}

function compat_warning() {
	echo_red "OMC Light curve is in another script! please use launch_scw_job with any of ISDC_one.scripts"
}

function launcher_omc_lc() {
     compat_warning    
}

function launcher_jemx() {
    compat_warning    
}

function launch_scw_job() {
    job_script=${1:?first arg is job script[}
    shift 1
    args=$@
    job_scw=${1:?needs some args, at least job scw}

    echo $job_scw |  grep -E '[0-9]{12}' || { echo_red "scw \"$job_scw\" does not conform"; exit 1; }

    script_hashe=$(cat $job_script | md5sum | cut -c1-8) # unique version of the script

    logdir=$PWD/work/logs/$(basename $job_script)/$script_hashe
    mkdir -pv $logdir

    # can export here osa_version=10.2 or so 
    sbatch -o "$logdir/${job_scw}.log" $(which isdc-singularity) "$(realpath $job_script) $args"
}

function launcher_isgri() {
    compat_warning    
}


function launch_by_scw() { 
    osa=${1:?osa11 or osa11! (for now)} 
    scw_script=${2:?scw script}

    [ -s $scw_script ] || { echo "should exist: $scw_script"; exit 1;} 

    dol_name=${3:-work/scwlist.txt}

    echo_red "will launch!"

    for dir in $(cat $dol_name); do
        echo $dir
        echo "launching launcher: $scw_script"

	set -x
        launch_scw_job $scw_script $dir 1
	set +x
    done
}

function watch_and_tail(){
    while true; do squeue -u savchenk | grep -v R || break; sleep 1; done; tail -n 1000 -f $(ls -tr work/logs/ISGRI_onescw.sh/*/* | tail -1)
}

function launch_mosaic() {
    set -x
    qsub -hold_jid "I_*" -N I_MOSA -q test  ISGRI_mosa.csh obs "2129*"

    echo "qsub -hold_jid J1_* -N J1_MOSA -q test  JEMX1_mosa.sh 2129* "
    qsub -hold_jid "J1_*" -N J1_MOSA -q test  JEMX1_mosa.sh "2129*"
}

function list-last-logs() {
	find  work/logs/ -type f -ctime -1 | xargs ls -ltr
}

function tail-last-log() {
	find  work/logs/ -type f -ctime -1 | xargs ls -tr | tail -1 | xargs tail -n 1000 -f
}

function download-data() {
	scw=${1:?scw here}

	set -x

	INTEGRAL_DATA=/isdc/arc/rev_3/ \
		bash <( curl https://raw.githubusercontent.com/volodymyrss/dda-ddosadm/master/download_data.sh ) ${scw::4} $scw
}

function test-all() {
	echo_red "no tests yet!"
}


function download-selected-data() {
	scwlist=${1:-work/scwlist.txt}

	set -x

	for scw in $(cat $scwlist); do
		download-data $scw; 
	done
}
    

if [ "$cmd" == "" ]; then
    C_STRONG="\033[32m"
    C_SUCCESS="\033[32m"
    C_COMMAND="\033[35m"
    C_NO="\033[0m"
    echo -e "

            $C_STRONG Prepared-For       $C_NO INTEGRAL users
            $C_STRONG Prepared-By        $C_NO VS
            $C_STRONG See-Also           $C_NO https://redmine.astro.unige.ch/issues/21574
            $C_STRONG Reference-Location $C_NO https://github.com/volodymyrss/isdc-cli/blob/master/actions.sh
            $C_STRONG Metadata-Schema    $C_NO https://redmine.astro.unige.ch/projects/cdci/wiki/Metadata-Schema

"
    cat ${HOME}/.local/share/doc/isdc-cli.md | awk '
		/^#/ && ! /^## isdc-cli/ { on = 0 }

		on == 1 {
			gsub("```bash", "'$C_COMMAND'")
			gsub("```", "'$C_NO'")
			print "      "$0
		}

		/^## isdc-cli/ { on = 1 }
	'

    echo_red "all available functions:"
    cat $0 | egrep '^function ' | awk '{print "   "$2}'


else
    echo "running $cmd" # no to set -x 
    
    $cmd
fi

