#!/bin/sh

#       0. Starting files location
starting_files_location=/share/lemaylab-backedup/Zeya/raw_data/NovaSeq043/tb957t8xg/Un_DTDB73/Project_DLZA_Nova043P_Alkan

unzipped_files_output=/share/lemaylab-backedup/Zeya/proceesed_data/NovaSeq043/unzipped

# for loop to unzip all gz file to fastq in one file 
for file in $starting_files_location/*fastq.gz
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

