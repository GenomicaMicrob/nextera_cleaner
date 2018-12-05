#!/bin/bash
AUTHOR='Bruno Gomez-Gil' # Laboratorio de Genomica Microbiana, CIAD. https://github.com/GenomicaMicrob
NAME='nextera_cleaner'
REV='Dec. 05, 2018'
VER='v0.1.0'
LINK='https://github.com/GenomicaMicrob/nextera_cleaner'
DEP='cutadapt > v1.16, FastQC > v0.11, flash > v1.2.11'
TCPUS=$(nproc) # total number of CPUs available

# CONFIGURATION ---------------------------------------------------------------
# You might want to configure this variables to suit your need and resources,
# just change the values after the equal sign ( = )
CPU=8 # Number of cores to be used
DB=/databases/ # Path to the adapter and contaminant databases
Q=30 # Quality score
m=20 # Minimum length of the sequences

# HELP AND VERSION ------------------------------------------------------------
display_version(){
echo -e "
____________________________________________________________________

Script name:    \e[1m$NAME\e[0m
Version:        \e[1m$VER\e[0m
Author:         $AUTHOR
Last revisited: $REV
Dependencies:   $DEP
More info at:   $LINK
____________________________________________________________________

"
}
if [ "$1" == "-v" ]
	then
		display_version
		exit 1
fi # -v is typed, display_version

display_help(){
echo -e "
____________________ $NAME $VER ______________________________

A script to clean pair-end sequences produced with nextera.

\e[1mUSAGE\e[0m: $NAME.$VER file_R1.fastq file_R2.fastq

This script will process both pair-end sequences, asks for a common
name for the resulting sequences, trims bases below Q$Q, removes N's
and sequences below 20 bases. It can also deletes bases from the
beggining of the sequences and also trim the sequences to a certain length
by removing bases from the 3' end of the sequence.
If files are compressed (.gz) it will automatically decompress them.
After this, it will ask whether you want to merge the pair-end sequences
and run FastQC on resulting files.

More info, type $NAME.$VER with any of the following flags
   -c  Shows the configuration parameters.
   -v  Shows the version and details of the script.
   -h  Shows this very helpful screen.

Cleaning and assembling might take some time. If the terminal is disconnected,
or you decide to close you connection, the process will continue.
To stop the process type: Ctrl z
_________________________________________________________________________

"
}
if [ "$1" == "-h" ]
	then
		display_help
		exit 1
fi 	# -h is typed, displays help

display_configuration(){
echo -e "
____________________________________________________________________
 
Main configuration parameters for $NAME.$VER

Number of cores:             \e[1m$CPU\e[0m ($TCPUS available)
phred quality score:         \e[1mQ$Q\e[0m
Minimum length of sequences: \e[1m$m\e[0m
Path to adapters database:   \e[1m$DB\e[0m

To change this parameter edit the script's code.
Just change the values after the equal sign ( = ) in
the 'configuration' section at the top of the script.
____________________________________________________________________
"
} 
if [ "$1" == "-c" ]
	then
		display_configuration
		exit 1
fi # -c is typed, displays configuration

display_usage(){
echo -e "
____________________ $NAME $VER ______________________________

\e[1mERROR\e[0m: missing filenames

USAGE: nextera_cleaner file_R1.fastq file_R2.fastq

   fastq files are the files produced by the Illumina sequencer.
   If files are compressed (.gz) it will automatically decompress them.

_________________________________________________________________________

"
}
if [  $# -le 1 ] 
	then 
		display_usage
		exit 1
fi # less than 2 arguments supplied, display usage 

# --- Dependencies check-up -----------------------------------------------------------------------
command -v cutadapt >/dev/null 2>&1 || { echo >&2 "Cutadapt is not installed.  Aborting."; exit 1; }
CUTADAPT_VER=$(cutadapt --version)
FLASH_VER=$(flash --version | head -n1 | cut -d " " -f2)

# Script start ----------------------------------------------------------------
NAMER1=$(basename $1 .fastq) # obtains only the name of the first file without the extension
NAMER2=$(basename $2 .fastq) # obtains only the name of the second file without the extension
mkdir -p original_files
mv $1 $2 original_files

echo "_________ $NAME $VER ____________________________________________________________________

Script to clean Illumina pair-end sequences produced with the Nextera kit.
Bases below Q30, Ns, and Nextera adapters are removed. Bases can also
be removed at the beginning and end of each sequence.

"
read -p "Enter a common name for the output files: " NAME
read -p "How many bases will be trimmed from the beggining of the sequences? Enter value (0 if none): " BP
read -r -p "Will the sequences be trimmed to a certain length? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		read -p "Enter value : " LEN
		echo
		cutadapt -a CAAGCAGAAGACGGCATACGAGAT -a CTGTCTCTTATACACATCT -A AATGATACGGCGACCACCGAGATCTACAC --times 2 -q $Q -m $m --trim-n -o $NAME.R1.fastq -p $NAME.R2.fastq -u $BP -l $LEN original_files/$1 original_files/$2 # -a -A nextera adapters
		echo Done
	else
		cutadapt -a CAAGCAGAAGACGGCATACGAGAT -a CTGTCTCTTATACACATCT -A AATGATACGGCGACCACCGAGATCTACAC  --times 2 -q 30  -m $m --trim-n -o $NAME.R1.fastq -p $NAME.R2.fastq -u $BP original_files/$1 original_files/$2 # -a -A nextera adapters
		echo Done
fi

# merger ----------------------------------------------------------------------
read -r -p "Do you want to merge the pair-end sequences? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		mkdir merged
		flash --output-prefix=$NAME --threads=$CPU $NAME.R1.fastq $NAME.R2.fastq --output-directory=merged
		mv merged/$NAME.extendedFrags.fastq merged/$NAME.merged.fastq
		mv merged/$NAME.notCombined_1.fastq merged/$NAME.notmerged.R1.fastq
		mv merged/$NAME.notCombined_2.fastq merged/$NAME.notmerged.R2.fastq
		# fq2fa ------------------------------------------------------------------------
		read -r -p "Do you want to convert the merged fastq files to fasta? [y/N] " response
		if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
			then
				# fastq to fasta
				echo -e "\e[1mConverting merged fastq files to fasta\e[0m"
				sed -n '1~4s/^@/>/p;2~4p' merged/$NAME.merged.fastq > merged/$NAME.merged.fasta
				sed -n '1~4s/^@/>/p;2~4p' merged/$NAME.notmerged.R1.fastq > merged/$NAME.notmerged.R1.fasta
				sed -n '1~4s/^@/>/p;2~4p' merged/$NAME.notmerged.R2.fastq > merged/$NAME.notmerged.R2.fasta
			else
				echo
		fi
	else
		echo
fi

# fastqc ----------------------------------------------------------------------
read -r -p "Do you want to run FastQC on the cleaned files? [y/N] " response
if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		mkdir fastqc
		fastqc --adapters nextera_adapters.tsv --contaminants contaminants.tsv --threads $CPU --outdir fastqc $NAME.R1.fastq $NAME.R2.fastq
	else
		echo
fi
echo
echo -e "\e[1mYour original fastq files were saved to a new subdirectory\e[0m"
echo ____________________________________________________________________________________
echo
# This is the end.