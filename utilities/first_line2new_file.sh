#!/bin/bash

# This script takes the first line of each file in the the loop 
# and writes the lines to a new file 

# Usage: first_line2new_file.sh filepath outfile

# Clear the contents of the output file in case there is previous contents
> $2 

for file in $1/*_report
do 
	STEM=$(basename "$file" _report)
	line=$(head -n 1 $file)

	# add both info to a new line 
	echo $STEM	$line >> $2
done	
