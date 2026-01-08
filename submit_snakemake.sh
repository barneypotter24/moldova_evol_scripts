#!/bin/bash

#SBATCH --job-name=snakemake-main-job
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --output=slurm_logs/%x-%j.log
#SBATCH --mail-type=ALL
#SBATCH --job-name=Array_TBAssemble
#SBATCH --array=0-5:1

echo "Slurm job ID SLURM_ARRAY_JOB_ID is ${SLURM_ARRAY_JOB_ID}"
echo "Slurm job array index SLURM_ARRAY_TASK_ID is ${SLURM_ARRAY_TASK_ID}"

echo "LOADING CONDA"
module load miniconda
echo "activating conda"
conda activate
echo "activating conda environment"
conda activate tb-assemble

CFG_FILE=Batch3/config/2_combined/config${SLURM_ARRAY_TASK_ID}.yaml
echo "Configuration file CFG_FILE is ${CFG_FILE}"

mkdir -p slurm_logs
export SBATCH_DEFAULTS=" --output=slurm_logs/%x-%j.log"

# tb-profiler update_tbdb --match_ref H37Rv.fasta ## run this if tb-profiler is failing to match locations

date
time snakemake -s Snakefile_combined --cores all --use-conda -j 1 -w 30 --rerun-incomplete --rerun-triggers mtime --configfile ${CFG_FILE} --nolock
date
