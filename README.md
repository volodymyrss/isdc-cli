# Baobab-Bash adaption

## Install it!

You can also install it in your local space:

```bash
git clone https://github.com/volodymyrss/isdc-cli.git && make -C isdc-cli install
```

and then use `isdc-cli` and `isdc-singularity` commands.

## isdc-singularity

Script to run any command with the container.
Environment variables are passed transparently.
Home is mounted in the same location.

But other directory layout is different inside and outside. One needs to be cautious, but this also gives an oppportunity to mimic any layout inside (e.g. /isdc/arc/rev_3 inside). To make other scripts happy.

Note that this script can be used inside submission scripts, but it is not possible to submit from inside of it.
I would just prefix all OSA-specific commands with `isdc-singularity`.

Examples:

```bash
[savchenk@login2 ISDC]$ isdc-singularity pwd
singularity-osa with command: "pwd"
found headas in /opt/heasoft/x86_64-unknown-linux-gnu-libc2.17/
/home/users/s/savchenk/Misc_Scripts/ISDC
```

only caution that variables passed in the command line might be substituted in the local shell. Any other variables inside will behave as expected.
But this need to escape:

```bash
$ isdc-singularity echo \$ISDC_ENV
isdc-singularity with command: "echo $ISDC_ENV"
found headas in /opt/heasoft/x86_64-unknown-linux-gnu-libc2.17/
/opt/osa
```

scripts should run as if they are run with normal OSA:

```bash
$ isdc-singularity bash ISGRI_onescw.sh 190400220010 1
```

archive is mounted inside in "usual" location and in local directory:

```bash
$ isdc-singularity ls -lotr /isdc/arc/rev_3/scw | wc -l
2123
$ isdc-singularity ls -lotr ./scw | wc -l
2123
```

you may want to:
	
download some data (you may not want to just add this to the analysis without taking care of restricting threading)

```bash
$ isdc-singularity isdc-cli download-data 066500220010
```
run one scw right here:

```bash
$ isdc-singularity ./ISGRI_onescw.sh 206300290010 1
```
## isdc-cli

submit one scw ISGRI:

```bash
$ isdc-cli launcher_isgri ISGRI_onescw.sh 206300290010
```

and launch them all:

```bash
$ isdc-cli launch_by_scw osa11 ./ISGRI_onescw.sh
```

## Case workflows

can be found here: https://github.com/ferrigno/osa-hpc-scripts

ISGRI_onescw.sh

or

JEMX1_onescw.sh

If I need to extract spectrum or lightc curve I run the script

com_extract.sh

If I need a mosaic, I use ISGRI_mosa.csh after some editing


## Relation to cli-bao-ygg-unige

this very useful tooling is also used to access bao-ygg.

https://github.com/volodymyrss/cli-bao-ygg-unige

But it is used solely on client side, synchronizing locations on remote clusters, avoiding any need of tracking versions of software over different systems. It is also uploading software and data on the remote clusters as necessary.

isdc-cli, on the other hand, is used on the cluster itself. It is one of the payloads which can be uploaded on the clusters with cli-bao-igg.

Both tools can be used in conjunction.

If only one cluster is used one may stick to more tradititional isdc-cli interface.

