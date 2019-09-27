#!/bin/sh

#### Created by Zeya Xue on 09.27.2019


############################################################
# 1. download the most up to date human reference genome from NCBI RefSeq
######This only needs to be run one time for downloading. If you have already downloaded the ref genome, proceed to step 2 directly

# download script from https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/
#rsync --copy-links --recursive --times --verbose rsync://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.39_GRCh38.p13 /share/lemaylab-backedup/milklab/database/human_GRCh38_p13

# check sums to make sure that the .gz sequence files are completely download
db_path=/share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13
cksum_output=/share/lemaylab-backedup/milklab/database/human_GRCh38_p13/

for file in $db_path/*.gz; do
	md5sum $file >> $cksum_output/computed_check_sums.txt
	sed -i "s|$path|./|g" $cksum_output/computed_check_sums.txt
done

diff $cksum_output/computed_check_sums.txt /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13/md5checksums.txt >> /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/diff.txt
