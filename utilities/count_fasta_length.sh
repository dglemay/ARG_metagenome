#!/bin/bash


# The awk command is modified based on answers from this post
# https://www.biostars.org/p/373962/
# $1 is input file
# $2 is output file name

# usage: source count_fasta_length.sh inputfile outputfile
awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length($0)}END{print l}' $1 | paste - - | sed 's/>//g' >> $2 

