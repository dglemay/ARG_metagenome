#!/bin/bash 

######################################################################################################################
# Filename: kraken2_struo_95.sh                                                                                      #
#                                                                                                                    #
# Purpose: run kraken2/bracken on NovaSeq reads or the unclassified reads with new database: struo GTDB_release95    #
#                                                                                                                    #
# Author: Yirui Tang                                                                                                 #
#                                                                                                                    #
# Date: 02/25/2021
######################################################################################################################


kraken2_location=/share/lemaylab-backedup/milklab/programs/kraken2-2.0.9b/kraken2
bracken_location=/share/lemaylab-backedup/milklab/programs/Bracken-2.6.0
db=/share/lemaylab/yirui/databases/kraken2_struo_GTDB_release95

run_dir=/share/lemaylab/yirui
dup_outdir=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq043/step3_fastuniq
mkdir $run_dir/processed_data/NovaSeq043_rerun
kraken2_outdir=$run_dir/processed_data/NovaSeq043_rerun

# set an empty string variable to get all the names of samples
names='' 

for file in $dup_outdir/*_R1_dup.fastq.gz
do
	STEM=$(basename "$file" _R1_dup.fastq.gz )
	echo "processing sample $STEM"

	# set names parameter for Bracken
	names+=$STEM
	names+=','

	file2=$dup_outdir/${STEM}_R2_dup.fastq.gz

	$kraken2_location --db $db --threads 35 --confidence 0.2 --gzip-compressed \
	--report $kraken2_outdir/${STEM}_report \
	--unclassified-out $kraken2_outdir/${STEM}_unmap_R#.fq \
	--report-zero-counts --paired $file $file2 > $kraken2_outdir/${STEM}_kraken2.out 

	# Run Bracken for Abundance Estimation
	python2 $bracken_location/src/est_abundance.py -i $kraken2_outdir/${STEM}_report -k $db/database150mers.kmer_distrib -l G -t 10 -o $kraken2_outdir/${STEM}_genus_abundance.tsv

done

# delete the last "," 
names=${names::-1}

# combine all the Bracken output files to a single file
## script was written in python2, not currently compatible with python3 yet
python2 $bracken_location/analysis_scripts/combine_bracken_outputs_re.py --names $names --output $kraken2_outdir/merged_genus_abundance.tsv --files $kraken2_outdir/*_genus_abundance.tsv

echo "KRAKEN2 DONE AT: "; date
