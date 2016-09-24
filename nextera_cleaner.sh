#!/bin/bash
# Author: Bruno Gomez-Gil, Laboratorio de Genomica Microbiana, CIAD.
# Script to clean Illumina Nextera pair-end sequences.
# Version: 0.1 23-Sep-2016
# Usage: nextera_cleaner.sh file_R1.fastq file_R2.fastq
# Dependencies: Trim_galore!, Fastx toolbox,
echo ____________________________________________________________________________________
display_usage(){
	echo -e "\e[1mERROR\e[0m: missing filenames"
	echo "USAGE: nextera_cleaner file_R1.fastq file_R2.fastq"
	echo
	echo -e "   fastq files are the files produced by the Illumina sequencer"
	echo
echo ____________________________________________________________________________________
}
# if less than 2 arguments supplied, display usage 
	if [  $# -le 1 ] 
	then 
		display_usage
		exit 1
	fi
	
	# Script start--------------------------------------------
	NAMER1=$(basename $1 .fastq) # obtains only the name of the first file without the extension
	NAMER2=$(basename $2 .fastq) # obtains only the name of the second file without the extension

	mkdir -p trimmed
	echo
	echo Script to clean Illumina pair-end sequences produced with the Nextera kit.
	echo Bases below Q30, Ns, and Nextera adapters are removed. Bases can also
	echo be removed at the beginning and end of each sequence.
	echo
	read -p "Enter a common name for the output files: " NAME
	read -p "How many bases will be trimmed from the beggining of the sequences? Enter value (0 if none): " BP
	read -r -p "Will the sequences be trimmed to a certain length? [y/N] " response

		if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
		then
			read -p "Enter value : " LEN
			echo
			trim_galore -a CAAGCAGAAGACGGCATACGAGAT -a2 AATGATACGGCGACCACCGAGATCTACAC -q 30 --trim-n -o trimmed/ --clip_R1 $BP --clip_R2 $BP --paired $1 $2
			echo "Trimming to no more than $LEN bases in length"
			# Trimming running in parallel:
			fastx_trimmer -l $LEN -i trimmed/$NAMER1'_val_1.fq' -o trimmed/$NAME"_R1.fastq" &
			fastx_trimmer -l $LEN -i trimmed/$NAMER2'_val_2.fq' -o trimmed/$NAME"_R2.fastq" &
			wait
			rm -f trimmed/*.fq # clean up of files
			echo Done
		else
			trim_galore -a CAAGCAGAAGACGGCATACGAGAT -a2 AATGATACGGCGACCACCGAGATCTACAC -q 30 --trim-n -o trimmed/ --clip_R1 $BP --clip_R2 $BP --paired $1 $2
			mv trimmed/$NAMER1'_val_1.fq' trimmed/$NAME"_R1.fastq"
			mv trimmed/$NAMER2'_val_2.fq' trimmed/$NAME"_R2.fastq"
			rm -f trimmed/*.fq # clean up of files
		fi
	echo=====================================================================================================
	# FastQC-----------------------------------------------------------------------------------------------------
	read -r -p "Do you want to run FastQC? [y/N] " response
	if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		fastqc -a nextera_adapters.txt trimmed/*.fastq 
	else
		exit 0
		echo
	fi

echo ____________________________________________________________________________________
echo
# This is the end.
