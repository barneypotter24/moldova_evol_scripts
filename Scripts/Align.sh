#!/bin/bash

# Initialize variables
threads=""
Ref=""
input=()
prefix=""

# make directories if not present
mkdir -p BAMs VCFs Stats TBProfiler

# Usage
usage() {
    echo "Usage: $0 -i input_file(s) -r reference -t threads -p prefix"
    exit 1
}

# Parsers 
while getopts "i:r:t:p:" opt; do
    case "${opt}" in
        i)
            input+=("${OPTARG}")
            ;;
        r)
            Ref="${OPTARG}"
            ;;
        t)
            threads="${OPTARG}"
            ;;
        p)
            prefix="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done

# Check if all options are provided
if [ -z "${input}" ] || [ -z "${Ref}" ] || [ -z "${threads}" ] || [ -z "${prefix}" ]; then
    usage
fi

# Concatenate input files into a single string
input_files=$(printf " %s" "${input[@]}")
input_files=${input_files:1}

# Run BWA, SAMtools, and GATK commands
bwa mem -t $threads $Ref $input_files > ${prefix}.sam
samtools view -bS ${prefix}.sam > ${prefix}_pre.bam; rm ${prefix}.sam
samtools sort -@ $threads -o ${prefix}_sort.bam ${prefix}_pre.bam; rm ${prefix}_pre.bam
samtools index ${prefix}_sort.bam
gatk AddOrReplaceReadGroups -I ${prefix}_sort.bam -O ${prefix}.bam -SO coordinate -ID foo -LB bar -PL illumina -PU unit1 -SM ${prefix} --CREATE_INDEX TRUE; rm ${prefix}_sort.bam ${prefix}_sort.bam.bai
gatk HaplotypeCaller --native-pair-hmm-threads $threads -R $Ref -I ${prefix}.bam --max-reads-per-alignment-start 0 --emit-ref-confidence GVCF -O ${prefix}.vcf
samtools flagstat ${prefix}.bam > ./Stats/${prefix}_flagstat.txt
tb-profiler profile -a ${prefix}.bam -p ./TBProfiler/${prefix}
mv ${prefix}.ba* ./BAMs/
mv ${prefix}.vcf* ./VCFs/

