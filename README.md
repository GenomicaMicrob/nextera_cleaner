# nextera_cleaner
Bash script to clean Illumina pair-end sequences produced with the Nextera kit. Bases below Q30, Ns, and Nextera adapters are removed. Bases can also be removed at the beginning and end of each sequence. At the end, clean files can be analyzed with FastQC.

## INSTALLATION ##

Download **nextera_cleaner.sh** and **nextera.adapter** to any directory in your system and as with any bash script, just make it executable: ```chmod +x nextera_cleaner.sh```

You need the **nextera.adapter** file in the same folder as the script; this file is necessary for FastQC.

## USAGE ##

`$ nextera_cleaner file_R1.fastq file_R2.fastq`

Where `file_R1.fastq` `file_R2.fastq` are the files provided by the Illumina sequencer.

The script will ask if you want to trim some bases at the beginning of the sequences and also at the end. In order to give an appropriate number in both cases, it is recommended first to run FastQC with the raw secuences (file_R1.fastq file_R2.fastq), check the output and then decide if you need to trim. 

## DEPENDENCIES ##

You need the following programs in your PATH:

-[Trim_galore](https://github.com/FelixKrueger/TrimGalore)

-[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc)

-[FASTX-Toolkit](https://github.com/agordon/fastx_toolkit)

-[Cutadapt](https://github.com/marcelm/cutadapt)
