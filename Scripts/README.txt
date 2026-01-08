#########################################################################
############## For alignment and variant calling of Mtb #################
#########################################################################


##### Creating reference strain index files from FASTA (H37Rv.fasta)

1. Run  the following commands:

	bwa index H37Rv.fasta
	samtools faidx H37Rv.fasta
	gatk CreateSequenceDictionary H37Rv.fasta


##### Reference mapping and variant calling

1.	Align.sh will map the sequence data to a reference genome and create sorted, indexed BAM files placed into a /BAMs/ folder.
	
	Next, per sample variant calling is performed with GATK and placed into a /VCFs/ folder. 
	
	TB-profiler will be run and the output placed into the /TBProfiler/ folder. (This will create per sample .json files - to get a table of results you will need to run: tb-profiler collate -d TBProfiler) 
	
	Finally, the BAM stats showing mapping % etc will be output to the /Stats/ folder.
	
	This script can be run with the following command:
	
	
	./Align.sh -i read1.fastq.gz -i read2.fastq.gz -r H37Rv.fasta -p prefix -t 32
	
	-i = FASTQ(s) of sequencing data (can be 1 or 2 input if single- or paired-end reads)
	-r = reference strain FASTA
	-p = prefix for output files
	-t = number of threads

##### First time using Align.sh (or if you change reference strains) please run the following to update the TB-Profiler DB in your conda for the H37Rv.fasta reference sequence.
	
	tb-profiler update_tbdb --match_ref H37Rv.fasta

	
2.	After running Align.sh on all samples, VariantCall.sh will perform multi-sample variant calling using GATK to produce multi-sample VCF files of SNPs and Indels.

	This can be run with the following commands:
	
	cd VCFs/
	ls *GATK.vcf > Names.list
	./VariantCall.sh -i Names.list -r H37Rv.fasta -p prefix -c NC_000962.3 -t 32
	
	-i = file with names of per-sample VCF files
	-r = reference strain fasta
	-p = prefix for output files
	-c = chromosome name of reference strain (NC_000962.3 for H37Rv)
	-t = number of threads
	
3.	You will now have 5 new VCF files - prefix_allvariants.vcf, prefix_SNPs.vcf, prefix_INDELs.vcf, prefix_SNPs_filtered.vcf, prefix_INDELs_filtered.vcf.
	
	Next we will run vcfProcess.R to create a consensus sequence of SNPs (with and without reference sequence), binary alignment file for indels, and check for mixed infection using MixInfect2.
	
	This function will look for the following scripts so please make sure they are in the folder you are running the analysis from ("vcfProcess_functions.R", "MixInfect2_vcfProcess.R", "indelProcess_vcfProcess.R")
	
	This can be run with the following commands using the filtered VCF files:
	
	Rscript vcfProcess.R --inputfiles SNPs_filtered.vcf --outputfile Test --indelfiles INDELs_filtered.vcf --no.Cores 32 --processIndel TRUE --repeatfile MaskedRegions_repPEPPE.csv --hetasN FALSE --MixInfect2 TRUE --excludeMix FALSE

	These are the options:
	-i CHARACTER, --inputfiles=CHARACTER
		Input VCF files, comma-separated

	-o CHARACTER, --outputfile=CHARACTER
		Prefix for output files

	--indelfiles=CHARACTER
		Names of files containing INDELs if separate to SNPs, comma-separated

	-c INTEGER, --no.Cores=INTEGER
		Number of CPU cores to use

	--samples2remove=CHARACTER
		Samples to remove from multisample inputs

	--samples2include=CHARACTER
		Samples to include from multisample inputs

	--filter=LOGICAL
		Use the 'FILTER' column in VCF file to filter SNPs

	--processIndel=LOGICAL
		Process INDEL variants

	--DP_low=INTEGER
		Minimum read depth to consider call

	--lowqual=INTEGER
		Minimum variant quality to consider call

	--hetProp=NUMERIC
		Proportion allele frequency at hSNPs to assign call

	--hetasN=LOGICAL
		Code hSNPs as 'N' or by FASTA nucleic acid code

	--misPercent=INTEGER
		Percentage of sites missing across samples to remove variant

	--repeatfile=CHARACTER
		.csv file with start and stop coordinates for regions to remove variants

	--disINDEL=INTEGER
		Remove SNPs within int distance of INDELs

	--MixInfect2=LOGICAL
		Run MixInfect2 to test for mixed infections

	--excludeMix=LOGICAL
		Remove samples with a high likelihood of mixed infection

	-h, --help
		Show this help message and exit

	
	
	

