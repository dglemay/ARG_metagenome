#!/bin/bash

# Take input directory 
read -p "Enter input directory: " indir
# Enter output directory
read -p "Enter output directory: " outdir


# or used the head command
for file in $indir/500*.fastq 
do
	STEM=$(basename "${file}" .fastq)
	head -n 4000 $file > $outdir/${STEM}_1000reads.fastq
done
