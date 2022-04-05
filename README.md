# ARG_metagenome
Metagenomic analysis workflow for the identification and quantification of antimicrobial resistance genes (ARG) from human stool samples.
Authors = Zeya Xue, Yirui Tang, Danielle Lemay

## Please CITE
To be updated: paper currently under review

## Dowload software and databases
See the init/ folder for scripts that were used for dowloading and setting up software/databases. 
	
## Python packages 
https://bic-berkeley.github.io/psych-214-fall-2016/sys_path.html (read the "crude hack" part)

These python packages directly in the folder where the scripts are to help python look for the necessary packages.  

*numpy*
bin/
	f2py, Python module numpy.f2py
numpy
numpy-1.16.6.dist-info

*pytz*
pytzgit
pytz-2019.3.dist-info

*pandas*
pandas
pandas-0.24.2.dist-info

*six*
six-1.13.0.dist-info
six.py
six.pyc

*dateutil*

## ARG pipeline script
See the method_dev/ folder, individual steps are labelled with their step number and procedure. For example, step1_BMTagger.sh is for the 1st step in the AMR pipeline that removes human DNA with BMTagger. 

"ARG_pipeline_v0.X.sh" is the master script containing the entire AMR pipeline, with preferred software/method/order of sequence processing.

	+ compare_merged_fq_N.sh: count the number of N base in a fastq file 
	+ run_hts_Stat_xxx.sh: use hts software to generate pipeline status
	+ ARG_detection_limit.txt: Find the detection limit ARG (1 sequence count after MicrobeCensus normalization)

## Sequence Quality Control
See the sequence_QC/ folder
	
	+ hiseq_qc.sh: sequencing QC for two HiSeq runds
	+ hts_SeqScreener_Phix.sh: find PhiX sequences
	+ pipeline_stats.ipynb: Jupyter notebook to generate QC figures for raw and processed sequences  

## Taxonomy
See the taxonomy/ folder

	+ kraken2.sh: whole community taxonomy identification with Kracken2-Bracken pipeline
	+ megahit_kraken_unmap.sh: troubleshooting script that assembles unmapped reads from Kraken2 
	+ metaphlan2.sh: whole community taxonomy identification with metaphlan2 method

## Supportive scripts
See the utilties/ folder
	
	+ checksums_bash.sh: check sums for downloaded sequence files to make sure files ware not corrupted
	+ count_fasta_length.sh: calculate the length of fasta files
	+ count_fq_length.sh: calculate the length of fastq files
	+ count_fq.sh: count the number of reads in each fastq or fastq.gz file
	+ discover_adapter_sequences.sh: find adapter sequences from fastq files
	+ DNAtoAA_transcription_translation.py: transcribe DNA to amino acid sequences using the NCBI "11-bacterial" codon table
	+ first_line2new_file.sh: this script takes the first line of each file in the the loop and writes the lines to a new file 
	+ gunzip_loop.sh: unzip all sequence files in a loop
	+ human_ref_format4BMTagger.sh: format the human genome reference for BMTagger
	+ make_RPKG_normtab.py: supportive script that normalize the ARG data table with MicrobeCensus
	+ prefix_to_compline.py: converts partial headers extracted from sam file to full headers 
	+ subset_reads.sh: subset sequence files in a loop

