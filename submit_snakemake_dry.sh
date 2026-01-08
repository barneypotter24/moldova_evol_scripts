#!/bin/bash

#SBATCH --job-name=snakemake-main-job
#SBATCH --ntasks=4
#SBATCH --nodes=1
#SBATCH --time=00:05:00
#SBATCH --mem-per-cpu=1G
#SBATCH --output=slurm_logs/dry_%x-%j.log
#SBATCH --mail-type=ALL
#SBATCH --job-name=Test_Array_TBAssemble
#SBATCH --array=0-5:1

echo "Slurm Job ID SLURM_ARRAY_JOB_ID is ${SLURM_ARRAY_JOB_ID}"
echo "Slurm job arry index SLURM_ARRAY_TASK_ID is ${SLURM_ARRAY_TASK_ID}"

echo "LOADING CONDA"
module load miniconda
echo "activating conda"
conda activate
echo "activating conda environment"
conda activate tb-assemble

CFG_FILE=Batch3/config/2_combined/config${SLURM_ARRAY_TASK_ID}.yaml
echo "Configuration file CFG_FILE is ${CFG_FILE}"

mkdir -p slurm_logs
export SBATCH_DEFAULTS=" --output=slurm_logs/dry_%x-%j.log"

date
time snakemake -s Snakefile_combined --dry-run --cores 1 -j 4 --rerun-triggers mtime  --printshellcmds --max-checksum-file-size 1000 --configfile ${CFG_FILE}
date
