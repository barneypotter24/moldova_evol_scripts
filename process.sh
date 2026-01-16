#!/bin/bash
#SBATCH --job-name=process
#SBATCH --output=out_err/vcf_process%j.out
#SBATCH --error=out_err/vcf_process%j.err
#SBATCH --time=36:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=32
#SBATCH --account=cohen_theodore
#SBATCH --partition=week

## activate conda environment
source /vast/palmer/apps/avx2/software/miniconda/23.5.2/etc/profile.d/conda.sh
conda activate bioinfo-workshop

## load in R
module load R/4.4.1-foss-2022b

## vcfprocess file source
vcfprocess="/vast/palmer/pi/cohen_theodore/M_tuberculosis/moldova/moldova_evol/Scripts/vcfProcess.R"

## files to use
INPUT="/vast/palmer/pi/cohen_theodore/M_tuberculosis/moldova/moldova_evol/SNP_alignment/gatk_OUTPUT/SNPs_filtered.vcf"
INDEL="/vast/palmer/pi/cohen_theodore/M_tuberculosis/moldova/moldova_evol/SNP_alignment/gatk_OUTPUT/INDELs_filtered.vcf"

## running the file
cd /vast/palmer/pi/cohen_theodore/M_tuberculosis/moldova/moldova_evol/Scripts
Rscript $vcfprocess --inputfiles $INPUT --outputfile "01092026_group1MSA_" --no.Cores 32 --hetasN FALSE --MixInfect2 FALSE

## move output files to folder
OUTPUT_DIR="/vast/palmer/pi/cohen_theodore/M_tuberculosis/moldova/moldova_evol/vcf_process_OUTPUT"
mkdir -p $OUTPUT_DIR
mv ./*01092026_group1MSA_ $OUTPUT_DIR
