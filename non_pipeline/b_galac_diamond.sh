#!/bin/bash

# DIAMOND
diamond_location=/share/lemaylab-backedup/milklab/programs/diamond
db=/share/lemaylab-backedup/databases/b-galactosidase/db_with_B-galac.dmnd

####################################################################
#
# Align to CAZy database with diamond
# for diamond usage, read manual: https://github.com/bbuchfink/diamond

output_dir_flash=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/step4_flash
mkdir /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/b_galac_diamond
output_dir_diamond=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/b_galac_diamond

#for file in $output_dir_flash/*.extendedFrags.fastq
#do
#	STEM=$(basename "$file" .extendedFrags.fastq)
#
#	# eval chosen based on recommendations for 200-250bp reads
#	$diamond_location blastx --db $db -q $file -a $output_dir_diamond/${STEM}.daa -t ./ -k 1 --sensitive --evalue 1e-25
#	$diamond_location view --daa $output_dir_diamond/${STEM}.daa -o $output_dir_diamond/${STEM}.txt -f tab	
#done
#
#mv log.txt $output_dir_diamond/log.txt


## Organize the output of diamond files to readable csvs
#for file in $output_dir_diamond/*.daa
#do	
#	STEM=$(basename "$file" .daa)
#
#	#python /share/lemaylab-backedup/Zeya/scripts/ARG_metagenome/CAZy_db_analysis_counter.py \
#	#-ref /share/lemaylab-backedup/databases/b-galactosidase/B-galac_family_names.tsv \
#	#-I $output_dir_diamond/${STEM}.txt \
#	#-O $output_dir_diamond/${STEM}_org.txt
#
#	python /share/lemaylab-backedup/Zeya/scripts/ARG_metagenome/merge_organized_diamond_tab.py \
#	--in $output_dir_diamond/${STEM}_org.txt \
#	--out $output_dir_diamond/${STEM}_org_samid.txt \
#	--mergein $file # This argument does not do anything here, but python2 requires *args to be not empty so I supply a dummy argument 
#
#	python /share/lemaylab-backedup/Zeya/scripts/ARG_metagenome/merge_organized_diamond_tab.py \
#	--mergeout $output_dir_diamond/merged_diamond_tab.csv \
#	--mergein $output_dir_diamond/*_org_samid.txt
#done

# Get the taxonomy of b-gal reads
bbmap_location=/software/bbmap/37.68/static
mkdir /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/b_galac_diamond/taxonomy
bg_taxa_outdir=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/b_galac_diamond/taxonomy
step3_fastuniq=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq112/step3_fastuniq


kraken2_location=/share/lemaylab-backedup/milklab/programs/kraken2-2.0.9b/kraken2
bracken_location=/share/lemaylab-backedup/milklab/programs/Bracken-2.6.0
db=/share/lemaylab-backedup/databases/kraken2-bact-arch-fungi

for file in $output_dir_diamond/????.txt
do	
	STEM=$(basename "$file" .txt)
	echo "processing sample $STEM"

	# filter reads to contain only reads that have b-gal hits
	cut -f 1 $file > $bg_taxa_outdir/header.txt
	$bbmap_location/filterbyname.sh in=$step3_fastuniq/${STEM}_R1_dup.fastq in2=$step3_fastuniq/${STEM}_R2_dup.fastq out=$bg_taxa_outdir/${STEM}_filtered1.fastq out2=$bg_taxa_outdir/${STEM}_filtered2.fastq names=$bg_taxa_outdir/header.txt include=true

	# Assign taxonomy to these reads with kracken2
	# set names parameter for Bracken
	names+=$STEM
	names+=','


	$kraken2_location --db $db --threads 35 --confidence 0.2 \
	--report $bg_taxa_outdir/${STEM}_report \
	--report-zero-counts --paired $bg_taxa_outdir/${STEM}_filtered1.fastq $bg_taxa_outdir/${STEM}_filtered2.fastq > $bg_taxa_outdir/${STEM}_kraken2.out

	# Run Bracken for Abundance Estimation
	python2 $bracken_location/src/est_abundance.py -i $bg_taxa_outdir/${STEM}_report -k $db/database151mers.kmer_distrib -l S -t 10 -o $bg_taxa_outdir/${STEM}_species_abundance.tsv

done	

# delete the last "," 
names=${names::-1}

# combine all the Bracken output files to a single file
python2 $bracken_location/analysis_scripts/combine_bracken_outputs_re.py --names $names --output $bg_taxa_outdir/merged_species_abundance.tsv --files $bg_taxa_outdir/*_species_abundance.tsv

echo "DONE AT: "; date

