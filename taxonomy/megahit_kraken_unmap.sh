#!/bin/bash

megahit=/share/lemaylab-backedup/milklab/programs/MEGAHIT-1.2.9-Linux-x86_64-static/bin/megahit

# Use megahit to assemble umapped reads from kraken into contigs 
unmaped_outdir=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/kraken2_ver2
mkdir /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/kraken2_ver2/unmap_assembly
assembly_outdir=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/kraken2_ver2/unmap_assembly

for file in $unmaped_outdir/8060_unclass_1.fq
do
	STEM=$(basename "$file" _unclass_1.fq)
	
	# usage instruction at https://github.com/voutcn/megahit & http://www.metagenomics.wiki/tools/assembly/megahit
	# use 70% memory and 20 threads
	$megahit -1 $file  -2 $unmaped_outdir/${STEM}_unclass_2.fq \
	-m 0.7 -t 20 \
	-o $assembly_outdir/${STEM}_assembled
done

for file in $unmaped_outdir/9039_unclass_1.fq
do
	STEM=$(basename "$file" _unclass_1.fq)
	
	# usage instruction at https://github.com/voutcn/megahit & http://www.metagenomics.wiki/tools/assembly/megahit
	# use 70% memory and 20 threads
	$megahit -1 $file  -2 $unmaped_outdir/${STEM}_unclass_2.fq \
	-m 0.7 -t 20 \
	-o $assembly_outdir/${STEM}_assembled
done

for file in $unmaped_outdir/*_unclass_1.fq
do
	STEM=$(basename "$file" _unclass_1.fq)
	
	# usage instruction at https://github.com/voutcn/megahit & http://www.metagenomics.wiki/tools/assembly/megahit
	# use 70% memory and 20 threads
	$megahit -1 $file  -2 $unmaped_outdir/${STEM}_unclass_2.fq \
	-m 0.7 -t 20 \
	-o $assembly_outdir/${STEM}_assembled
done
