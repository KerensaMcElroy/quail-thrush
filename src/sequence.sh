#!/bin/bash

#***************************************************************#
#                           sequence.sh                         #
#                  written by Kerensa McElroy                   #
#                          January 2016				#
#                                                               #
#               processes raw data sequence data                #
#***************************************************************#

export TODAY=$(date +%Y-%m-%d_%H-%M)

#----------------------project variables------------------------#

export PROJECT=2018-06_quail-thrush
export REF=GCF_000151805.1_Taeniopygia_guttata-3.2.4_genomic.fna.gz
export PHRED=
export EXT=fastq.gz
export READ_ONE=_R1
export UNIT_RX=3-4

#-------------------environmental variables---------------------#

export BIG=/OSM/CBR/NRCA_FINCHGENOM
export METADATA=${BIG}/data/${PROJECT}/metadata.tsv

#------------------------bwa variables--------------------------#

export ALGORITHM=mem
#---------------------------set up------------------------------#

#generate directories
mkdir -p ${BIG}/data/${PROJECT}
mkdir -p ${BIG}/analysis/${PROJECT}
mkdir -p ${BIG}/results/${PROJECT}
mkdir -p ${BIG}/analysis/${PROJECT}/logs/slurm

#get genome data
#~/${PROJECT}/src/download.sh

#functions

call_prog () {
	CMD="sbatch --dependency=${2} ${HOME}/scripts/${1}.sh"
	echo -e "\nRunning command: \n${CMD}" >> ${BIG}/analysis/${PROJECT}/logs/${TODAY}_main.log
        mkdir -p ${BIG}/analysis/${PROJECT}/logs/slurm/
        mkdir -p ${BIG}/analysis/${PROJECT}/logs/${TODAY}_${1}_slurm
	local __jobvar=${1}
	JOB_ID=`echo $(${CMD}) | tr ' ' '\n' | tail -n1` 
	eval $__jobvar="'$JOB_ID'"
}

multi_prog () {
#	CMD="sbatch --dependency=${3} -a 0-${2} ${HOME}/scripts/${1}.sh"
        CMD="sbatch -a 0-${2} ${HOME}/scripts/${1}.sh"
	mkdir -p ${BIG}/analysis/${PROJECT}/logs/slurm
	mkdir -p $BIG/analysis/${PROJECT}/logs/${TODAY}_${1}_slurm
	echo -e "\nRunning command: \n${CMD}" >> ${BIG}/analysis/${PROJECT}/logs/${TODAY}_main.log
        local __jobvar=${1}
        JOB_ID=`echo $(${CMD}) | tr ' ' '\n' | tail -n1`
        eval $__jobvar="'$JOB_ID'"
}


#-------------------------analysis------------------------------#

cd $BIG

#call_prog bwa_index singleton

multi_prog bwa "$(expr $(cut -f 1 ${METADATA} | sed "s/_R[12].*//" | sort -u | wc -l) - 1)" "afterok:${bwa_index}"
multi_prog bam "$(expr $(cut -f 1 ${METADATA} | sed "s/_R[12].*//" | sort -u | wc -l) - 1)" "afterok:${bwa}"
multi_prog haplotype "$(expr $(cut -f 1 ${METADATA} | sed "s/_R[12].*//" | sort -u | wc -l) - 1)" 
multi_prog picard "$(expr $(cut -f 1 ${METADATA} | sed "s/_R[12].*//" | sort -u | wc -l) - 1)"
multi_prog geno "$(expr $(grep '>' ${BIG}/data/${REF} | cut -d'.' -f1 | cut -d'>' -f2 | sort -u | wc -l) - 1)"
