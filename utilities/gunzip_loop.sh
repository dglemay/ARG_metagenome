#!/bin/sh

#       0. Starting files location
starting_files_location=raw_data/NovaSeq072_rerun/Project_DLZA_Nova072P_Alkan_Pippin2

unzipped_files_output=proceesed_data/NovaSeq072_rerun/unzipped
mkdir proceesed_data/NovaSeq072_rerun
mkdir $unzipped_files_output

# for loop to unzip all gz file to fastq in one file 
for file in $starting_files_location/5*fastq.gz
do
	STEM=$(basename "${file}" .gz)

	if [ -f /$unzipped_files_output/"${STEM}" ]
	then 
		echo /$unzipped_files_output/"${STEM}".fastq already exist and will not be overwritten.
	else
		echo "${STEM}" does not exist. Unzipping now....		
		gunzip -c "${file}" > /$unzipped_files_output/"${STEM}"
  	fi		
done


