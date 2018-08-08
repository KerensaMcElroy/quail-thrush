#!/bin/bash

#SBATCH --job-name=copy
#SBATCH --time=00:20:00
#SBATCH --mem=20GB


IN_LIST=( $(cut -d',' -f1 ../data/metadata.csv) );

if [ ! -z "$SLURM_ARRAY_TASK_ID" ]
  then
    file=${IN_LIST["$SLURM_ARRAY_TASK_ID"]}
    cp /OSM/CBR/NRCA_FINCHGENOM/data/2015-11-12_libraries/$file /OSM/CBR/NRCA_FINCHGENOM/data/2018-06_quail-thrush/DAP/
  else
    echo 'problem'
fi
