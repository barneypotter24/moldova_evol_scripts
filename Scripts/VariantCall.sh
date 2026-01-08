#!/bin/bash

# Initialize variables
threads=""
Ref=""
input=""
prefix=""
chromosome=""
Database=Database_$(date +"%Y-%m-%d")_$(date +"%H:%M:%S")

# Usage
usage() {
    echo "Usage: $0 -i input -r Ref -p prefix -c chromosome -t threads"
    exit 1
}

# Parse options
while getopts "i:r:p:c:t:" opt; do
    case "${opt}" in
        i)
            input=("${OPTARG}")
            ;;
        r)
            Ref="${OPTARG}"
            ;;
        p)
            prefix="${OPTARG}"
            ;;
        c)
            chromosome="${OPTARG}"
            ;;
        t)
            threads="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done

# Check if all necessary options are provided
if [ -z "${input}" ] || [ -z "${Ref}" ] || [ -z "${threads}" ] || [ -z "${prefix}" ]; then
    usage
fi

gatk GenomicsDBImport -V $input --genomicsdb-workspace-path ./$Database -L $chromosome --reader-threads $threads
gatk GenotypeGVCFs -R $Ref -V gendb://$Database -O ${prefix}_allvariants.vcf
gatk SelectVariants -V ${prefix}_allvariants.vcf -select-type SNP -O ${prefix}_SNPs.vcf
gatk SelectVariants -V ${prefix}_allvariants.vcf -select-type INDEL -O ${prefix}_INDELs.vcf
gatk VariantFiltration -V ${prefix}_SNPs.vcf -filter "QD < 2.0" --filter-name "QD2" -filter "QUAL < 30.0" --filter-name "QUAL30" -filter "SOR > 3.0" --filter-name "SOR3" -filter "FS > 60.0" --filter-name "FS60" -filter "MQ < 40.0" --filter-name "MQ40" -O ${prefix}_SNPs_filtered.vcf
gatk VariantFiltration -V ${prefix}_INDELs.vcf -filter "QD < 2.0" --filter-name "QD2" -filter "QUAL < 30.0" --filter-name "QUAL30" -filter "FS > 200.0" --filter-name "FS200" -O ${prefix}_INDELs_filtered.vcf

