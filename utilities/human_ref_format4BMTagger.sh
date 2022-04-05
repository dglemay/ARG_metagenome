#!/bin/sh
#SBATCH --mem-per-cpu 2000
#SBATCH --mail-user=zhxue@ucdavis.edu
#SBATCH --mail-type=END

#### Created by Zeya Xue on 09.27.2019


############################################################
# 1. download the most up to date human reference genome from NCBI RefSeq
######This only needs to be run one time for downloading. If you have already downloaded the ref genome, proceed to step 2 directly

# download script from https://www.ncbi.nlm.nih.gov/genome/doc/ftpfaq/
#rsync --copy-links --recursive --times --verbose rsync://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/001/405/GCF_000001405.39_GRCh38.p13 /share/lemaylab-backedup/milklab/database/human_GRCh38_p13

# check sums to make sure that the .gz sequence files are completely download
db_path=/share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13
cksum_output=/share/lemaylab-backedup/milklab/database/human_GRCh38_p13/computed_check_sums.txt

#for file in $db_path/*.gz; do
#	md5sum $file >> $cksum_output
#	sed -i "s|$db_path||g" $cksum_output
#done

#diff $cksum_output /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13/md5checksums.txt >> /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/diff.txt

# move to my github account so I can see it more easily
# cp /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/diff.txt /share/lemaylab-backedup/Zeya/scripts/gitSRC/ARG_metagenome/diff.txt

############################################################
# 2. format reference
bmtool_location=/share/lemaylab-backedup/milklab/programs/bmtools/bmtagger/bmtool 
srprism_location=/share/lemaylab-backedup/milklab/programs/srprism/gnuac/app/srprism 

# unzip the zipped ref genome
gunzip -c /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13/GCF_000001405.39_GRCh38.p13_genomic.fna.gz > /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13_genomic.fna

ref_file=/share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13_genomic.fna

# Make index for bmfilter
$bmtool_location -d $ref_file -o /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13_genomic.bitmask -A 0 -w 18

# Make index for srprism
$srprism_location mkindex -i $ref_file -o /share/lemaylab-backedup/milklab/database/human_GRCh38_p13/GCF_000001405.39_GRCh38.p13_genomic.srprism -M 7168



