#!/bin/bash

# Initialize variables
threads=""
forward_read=""
reverse_read=""
genome_length=""
prefix=""

# Make output folders if not present
mkdir -p Assemblies QUAST Prokka BUSCO

# Usage
usage() {
    echo "Usage: $0 -f forward_read -r reverse_read -t threads -p prefix -g genome_length"
    echo " -f      : Path to forward read"
    echo " -r      : Path to reverse read"
    echo " -p      : Prefix for file names"
    echo " -t      : Number of threads"
    echo " -g      : Genome length (estimate)"
    exit 1
}

# Parsers 
while getopts "f:r:t:p:g:" opt; do
    case "${opt}" in
        f)
            forward_read="${OPTARG}"
            ;;
        r)
            reverse_read="${OPTARG}"
            ;;
        t)
            threads="${OPTARG}"
            ;;
        p)
            prefix="${OPTARG}"
            ;;
        g)
            genome_length="${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done

# Check if all options are provided
if [ -z "${forward_read}" ] || [ -z "${reverse_read}" ] || [ -z "${threads}" ] || [ -z "${prefix}" ] || [ -z "${genome_length}" ]; then
    usage
fi


# Run Spades, QUAST, BUSCO, Prokka

spades.py -s $forward_read -s $reverse_read -o $prefix -t $threads --isolate
mv ${prefix}/contigs.fasta Assemblies/${prefix}.fasta
quast Assemblies/${prefix}.fasta -o QUAST/${prefix}.fasta --threads $threads
busco -i Assemblies/${prefix}.fasta -l bacteria_odb10 -o BUSCO/${i} -m $genome_length -c $threads
prokka --outdir Prokka/${prefix} --prefix $prefix Assemblies/${prefix}.fasta --cpus $threads

