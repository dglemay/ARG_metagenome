#!/bin/sh

#       0. Starting files location
#starting_files_location=/share/lemaylab-backedup/Zeya/raw_data/Hiseq_qc072
#
#mkdir /share/lemaylab-backedup/Zeya/proceesed_data/Hiseq_qc072/ 
#mkdir /share/lemaylab-backedup/Zeya/proceesed_data/Hiseq_qc072/unzip
unzipped_files_output=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq122/unzipped

## for loop to unzip all gz file to fastq in one file 
#for file in $starting_files_location/*fastq.gz
#do
#	STEM=$(basename "${file}" .gz)
#
#	if [ -f $unzipped_files_output/"${STEM}" ]
#	then 
#		echo $unzipped_files_output/"${STEM}".fastq already exist and will not be overwritten.
#	else
#		echo "${STEM}" does not exist. Unzipping now....		
#		gunzip -c "${file}" > $unzipped_files_output/"${STEM}"
#  	fi		
#done
#



# STEP 4: Merge paired-end reads with FLASH
# The FLASH manual link: http://ccb.jhu.edu/software/FLASH/MANUAL

echo "NOW STARTING PAIRED-END MERGING WITH FLASH AT: "; date

# Flash join
flash_location=/share/lemaylab-backedup/milklab/programs/FLASH-1.2.11_2019/FLASH-1.2.11-Linux-x86_64/flash

mkdir /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq122/flash_qc
flash_outdir=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq122/flash_qc

for file in $unzipped_files_output/504*_R1_001.fastq
do
	STEM=$(basename "${file}" _R1_001.fastq)

	file1=$file
	file2=$unzipped_files_output/${STEM}_R2_001.fastq

	# -m: minium overlap length 10bp to be similar to pear 
	# -M: max overlap length 
	# -x: mismatch ratio, default is 0.25, which is quite high (e.g: 50bp overlap --> 12.5 mismatch by default)
	$flash_location $file1 $file2 -m 10 -M 100 -x 0.1 -o ${STEM} -d $flash_outdir
done

mv log /share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq122/log_qc

# Count read numbers
counter=/share/lemaylab-backedup/Zeya/scripts/ARG_metagenome/count_fq.sh
$counter fq $unzipped_files_output $unzipped_files_output/unzip_libsize.tsv
$counter fq $flash_outdir $flash_outdir/flash_libsize.tsv
