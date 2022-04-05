#!/bin/bash

# Discovering adapter sequences use BBmerge
# help page: https://jgi.doe.gov/data-and-tools/bbtools/bb-tools-user-guide/bbmerge-guide/

# load module to us bbmerge
module load java bbmap
# BBmerge location: /software/bbmap/37.68/static/bbmerge.sh

#mkdir /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq043/adapter_sequences

for file in /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq043/unzipped/500*R1_001.fastq
do 
	file1=$file
	file2=$(echo $file1 | sed 's/R1/R2/')

	STEM=$(basename "${file}" _L003_R1_001.fastq)
	echo "${STEM}"

	bbmerge.sh in=$file1 in2=$file2  outa=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq043/adapter_sequences/${STEM}_adapter.fasta
done	
