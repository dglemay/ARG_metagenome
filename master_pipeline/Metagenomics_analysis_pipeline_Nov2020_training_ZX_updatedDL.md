# Metagenomics analysis pipeline Nov2020 training ZX, updated DL April 2022

![](https://i.imgur.com/Mtdi8TH.png)





Initialize the work environment by downloading required python packages, see list here: `/init/install_python_packages`. 

Some python packages have to be downloaded in the same directory where your script sits for stability. See `/ARG_metagenome/README.md` for more info


Raw sequence files are downloaded from the sequencing core server. After the completion of downloading, check for “completeness” of files and make sure none of the downloaded files are corrupted. 
-	Script: `/utilities/checksums_bash.sh` 
-	Output: `checksum_man_112.txt`
-	Compare manually generated with checksums with the checksum file that was downloaded from the sequencing core server to ensure file integrity:
`diff @md5Sum.md5  checksum_man_112.txt`


## Step 0: Unzip the raw reads 
- Script: `/ARG_metagenome/gunzip_loop.sh`
- Input directory: Directory containing downloaded raw reads `raw_data/NovaSeq112/` 
- Output directory: This folder has now been removed to save space on spitfire. `$run_dir/unzipped` 

## Step 1: Remove human reads using BMTagger
- Initialization: script used to download and format human_GRCh38_p13 genome version. `/method_dev/human_ref_format4BMTagger.sh`
- Script: step 1 in `master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: unzipped files. `$run_dir/unzipped` 
- Output directory: `$run_dir/step1_BMTagger`

When running this step, there will be a warning message: "no ./bmtagger.conf found", which is fine. The `bmtagger.conf` file is not needed because `PATH` to dependencies are specified in the script already. 

## Step 2: Use Trimmomatic to remove low-quality reads
- Script: step 2 in `/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step1_BMTagger`
- Output directory: `$run_dir/step2_trim`


Trimmomatic parameters followed this paper (Taft et al., 2018, mSphere) and using the paired end mode.


This script removes any remaining adapter and trimming at the same time (TrueSeq3-PE-2.fa, PE1_rc and PE2_rc). The input adapter file `/milklab/programs/trimmomatic_adapter_input.fa`  may need to be modified if different library preparation method is used.

Manual: http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf

## Step 3: Remove duplicated reads with FastUniq 
- Script: step 3 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step2_trim`
- Output directory: `$run_dir/step3_fastuniq`

For FastUniq options: https://wiki.gacrc.uga.edu/wiki/FastUniq. I used default parameters

## Step 4: Merge paired-end reads with FLASH
- Script: step 4 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step3_fastuniq`
- Output directory: `$run_dir/step4_flash`

Parameters that need to be specified
-m 10: minium overlap length 10bp to be similar to pear 
-M 100: max overlap length (change depending on library prep)
-x 0.1: mismatch ratio, default is 0.25, which is quite high 

## Step 5: Run MicrobeCensus on paired-end reads to calculate genome equivalents per sample
- Initialization: see `/ARG_metagenome/init/install_MicrobeCensus.sh` for install MicrobeCensus 1.1.1
- Script: step 5 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step3_fastuniq`
- Output directory: `$run_dir/step5_MicrobeCensus`

Parameters that need to be specified
-n 100000000: subsampling read numbers, change per run depending library size. Alternatively, set a large enough number so that all reads are included.

## Step 5: Run MicrobeCensus on merged reads to calculate genome equivalents per sample
- Script: step 5_merged in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step4_flash`
- Output directory: `$run_dir/step5_MicrobeCensus_merged`

Parameters that need to be specified
-n 100000000: subsampling read numbers, change per run depending library size of merged reads. Alternatively, set a large enough number so that all reads are included.

## Step 6: Align to MEGARes database with bwa
- Initialization: see `/ARG_metagenome/init/install_MEGARes_v2.sh` for how to download and organze the MEGARes database
- Script: step 6 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step3_fastuniq`
- Output directory: `$run_dir/step6_megares_bwa`

## STEP 7. Count the MEGARes database alignment and normalize the count 
- Initialization: download resistome analyzer `/ARG_metagenome/init/install_Resistome_Analyzer.sh`
- Script: step 7 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step6_megares_bwa`
- Output directory for count table: `$run_dir/step7_norm_count_tab/resistomeanalyzer_output`
- Output directory for normalized count table: `$run_dir/step7_norm_count_tab/normalized_tab`

## STEP 8. Assemble reads into contigs with megaHIT
- Initialization: download MEGAHIT-1.2.9 `/ARG_metagenome/init/install_megaHIT.sh`
- Script: step 8 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step2_trim`
- Output directory: `$run_dir/step8_megahit_in_trimmomatic`

Make sure to use only paired-end reads for assembly. Merged reads may have low quality near the center of the reads, which will impact MEGAHIT performance. 

## STEP 9. Align short reads containing ARGs to contigs
- Script: step 9 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input directory: `$run_dir/step6_megares_bwa`
- Output directory for mapped ARG fastqs (mapped/aligned to MEGARes db): `$run_dir/step9_contig_bwa_nomerg/mapped_fastq`
- Output directory for ARG-contig alignment sam files: `$run_dir/step9_contig_bwa_nomerg`
- Output directory for contig fasta files: `$run_dir/step9_contig_bwa_nomerg`


## STEP 10. ID the taxonomy of contigs using CAT 
- Initialization: download CAT v5.0.3 `/ARG_metagenome/init/install_CAT.sh`
- Script: step 10 in `/ARG_metagenome/master_pipeline/ARG_pipeline_v0.3.sh`
- Input files: `$run_dir/step9_contig_bwa_nomerg/*.fa`
- Output directory: `$run_dir/step10_CAT`

## Community-wide taxa identification with kraken2 and bracken
- Initialization for kraken2: `/ARG_metagenome/init/install_kraken2`
- Initialization for bracken: `/ARG_metagenome/init/install_bracken`
- Script: `/ARG_metagenome/taxonomy/kraken2.sh`
- Input files:`$run_dir/step3_fastuniq`
- Output files: `$run_dir/kraken2_ver2`


