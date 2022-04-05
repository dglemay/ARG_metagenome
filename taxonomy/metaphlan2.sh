#!/bin/bash 

metaphlan=/software/metaphlan2-2.8/metaphlan2.py

run_dir=/home/AMR_metagenome/processed_data/Novaseq_072rerun
dup_outdir=$run_dir/step3_fastuniq
mkdir $run_dir/metaphlan2
mtp_outdir=$run_dir/metaphlan2


export PATH="/software/bowtie2-2.3.4.1/:$PATH"
export PATH="/software/metaphlan2-2.8/utils/read_fastx.py:$PATH"

for file in $dup_outdir/8024_R1_dup.fastq
do
	STEM=$(basename "$file" _R1_dup.fastq )
	echo "processing sample $STEM"

	file2=$dup_outdir/${STEM}_R2_dup.fastq


	python $metaphlan $file,$file2 --input_type fastq --bowtie2out $mtp_outdir/${STEM}2.bowtie2.bz2 --nproc 35 --bowtie2_exe /software/bowtie2-2.3.4.1/bowtie2 > $mtp_outdir/${STEM}_abundace.tsv

done

for file in $dup_outdir/8013_R1_dup.fastq
do
	STEM=$(basename "$file" _R1_dup.fastq )
	echo "processing sample $STEM"

	file2=$dup_outdir/${STEM}_R2_dup.fastq


	python $metaphlan $file,$file2 --input_type fastq --bowtie2out $mtp_outdir/${STEM}2.bowtie2.bz2 --nproc 35 --bowtie2_exe /software/bowtie2-2.3.4.1/bowtie2 > $mtp_outdir/${STEM}_abundace.tsv

done

for file in $dup_outdir/6093_R1_dup.fastq
do
	STEM=$(basename "$file" _R1_dup.fastq )
	echo "processing sample $STEM"

	file2=$dup_outdir/${STEM}_R2_dup.fastq


	python $metaphlan $file,$file2 --input_type fastq --bowtie2out $mtp_outdir/${STEM}2.bowtie2.bz2 --nproc 35 --bowtie2_exe /software/bowtie2-2.3.4.1/bowtie2 > $mtp_outdir/${STEM}_abundace.tsv

done

# merge output tables 
#python /software/metaphlan2-2.8/utils/merge_metaphlan_tables.py *_abundace.tsv > $mtp_outdir/merged_abundance.tsv
