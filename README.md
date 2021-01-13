I build a list of science windows (only SWID). (say e.g. list_scw.txt)

then I cd to /gpfs0/ferrigno/INTEGRAL/nrt_analysis for NRT or /gpfs0/ferrigno/INTEGRAL/scw_analysis for CONS

I edit the script launch_osa11.csh to select if I want to run ISGRI, or JEMX.

I build a catalog, a matrix (if needed) from somewhere.

I edit the scripts

ISGRI_onescw.sh

or

JEMX1_onescw.sh

to select the catalog, define parameters etc.

I run

./launch_osa11.csh list_scw.txt

If I need to extract spectrum or lightc curve I run the script

com_extract.sh

If I need a mosaic, I use ISGRI_mosa.csh after some editing

# Baobab-Bash adaption

two forms of adaption:

## singularity-osa.sh

Script to run any command with the container.
Environment variables are passed transparently.
Home is mounted in the same location.

But other directory layout is different inside and outside. One needs to be cautious, but this also gives an oppportunity to mimic any layout inside (e.g. /isdc/arc/rev_3 inside). To make other scripts happy.

Note that this script can be used inside submission scripts, but it is not possible to submit from inside of it.
I would just prefix all OSA-specific commands with ./singularity-osa.sh
See submission examples in the second section.

Examples:

```bash
[savchenk@login2 ISDC]$ ./singularity-osa.sh pwd
singularity-osa with command: "pwd"
found headas in /opt/heasoft/x86_64-unknown-linux-gnu-libc2.17/
/home/users/s/savchenk/Misc_Scripts/ISDC
```

only caution that variables passed in the command line might be substituted in the local shell. Any other variables inside will behave as expected.
But this need to escape:

```bash
$ ./singularity-osa.sh echo \$ISDC_ENV
singularity-osa with command: "echo $ISDC_ENV"
found headas in /opt/heasoft/x86_64-unknown-linux-gnu-libc2.17/
/opt/osa
```

scripts should run as if they are run with normal OSA:

```bash
$ ./singularity-osa.sh bash ISGRI_onescw.sh 190400220010 1
```

archive is mounted inside in "usual" location and in local directory:

```bash
$ ./singularity-osa.sh ls -lotr /isdc/arc/rev_3/scw | wc -l
2123
$ ./singularity-osa.sh ls -lotr ./scw | wc -l
2123
```


## Separating boilerplate functions

this was largely for myself since I had to run it somehow.
It is a list of actions as those described above by stored in a script.
I would use this for submitting jobs.

* keep boilerplate actions in different functions in one script: actions.sh
* allow calling all other provided scripts with no modifications

see all functions as so:

```bash
$ ./actions.sh
```

submit one job:

```bash
$ ./actions.sh launch_scw_job ISGRI_onescw.sh 190400220010 1
```

submit jobs from a default list (work/scwlist.txt):

```bash
$ ./actions.sh launch_by_scw osa11 ISGRI_onescw.sh
```


## Install it!

You can also install it in your local space:

```bash
make install
```

and then use `isdc-cli` and `isdc-singularity` commands, as replacement for `actions.sh` and `singularity-osa.sh` mentioned above.
