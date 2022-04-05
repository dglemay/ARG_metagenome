#!/bin/bash

# usage: count_fq.sh gz/fq indir outfile    

touch $2/count_fq_log.txt


if [ "$1" = "fq" ]
then 
	for file in $2/*.fastq
	do 
		STEM=$(basename "$file" .fastq)
		echo ${STEM} >> $2/count_fq_log.txt	
	 
		echo $(cat $file|wc -l)/4|bc >> $2/count_fq_log.txt
	done
elif [ "$1" = "gz" ]
then
	for file in $2/*.fastq.gz
	do 
		STEM=$(basename "$file" _R1_001.fastq.gz )
		echo ${STEM} >> $2/count_fq_log.txt	
	 
		echo $(zcat $file|wc -l)/4| >> $2/count_fq_log.txt
	done	
else 
	echo "Please input between fq and gz" 
fi

# organize file
cd $2

## # Make sampleID column
## ## I tried over several hours to wrangle the data in variables but that did not work
## awk 'NR%2==1' $2/count_fq_log.txt > $2/col1a.txt  
## # use $() to denote everthing between () are excutable commands
## $(echo sampleID > $2/col1b.txt) # column header
## $(sed 's/_.*//' $2/col1a.txt >> $2/col1b.txt) # need the . period symbol for wildcard to work
## 
## # Make read column
## $(echo lib_size > $2/col2.txt)
## awk 'NR%2==0' $2/count_fq_log.txt >> $2/col2.txt
## 
## # Combine 2 columns to final stats file
## $(paste $2/col1b.txt $2/col2.txt -d "\t" > $3)
## 
