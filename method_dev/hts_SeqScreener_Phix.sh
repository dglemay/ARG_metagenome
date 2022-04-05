#!/bin/bash

hts=/software/htstream/1.3.1/lssc0-linux/bin/hts_SeqScreener

dup_outdir=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/step3_fastuniq
mkdir /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/SeqScreener
seqscreen_outdir=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/SeqScreener


for file in $dup_outdir/*_R1_dup.fastq
do
	STEM=$(basename "$file" _R1_dup.fastq )
	echo "processing sample $STEM"

	$hts -1 $file -2 $dup_outdir/${STEM}_R2_dup.fastq -AL $seqscreen_outdir/${STEM}_seqscreen_log -f $seqscreen_outdir/${STEM}.fq

done	
