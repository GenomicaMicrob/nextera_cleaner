# nextera_cleaner
Bash script to clean Illumina pair-end sequences produced with the Nextera kit.

This script will process both pair-end sequences, asks for a common
name for the resulting sequences, trims bases below a Phred score value, removes N's
and sequences below 20 bases. It can also deletes bases from the
beggining of the sequences and also trim the sequences to a certain length
by removing bases from the 3' end of the sequence.
If files are compressed (.gz) it will automatically decompress them.
After this, it will ask whether you want to merge the pair-end sequences (with flash), convert them to fasta,
and run FastQC on resulting files.

## INSTALLATION ##

Download the latest [release](https://github.com/GenomicaMicrob/nextera_cleaner/releases/latest) to any directory in your system and, as with any bash script, just make it executable: ```chmod +x nextera_cleaner.v0.1.0.sh```

You need also the **nextera_adapter.tsv** and the **contaminants.tsv** files to the same folder as the script; this files are desirable for FastQC.

You can then create a symbolic link to the script so you call it from any directory.

## USAGE ##

`$ nextera_cleaner.v0.1.0.sh file_R1.fastq file_R2.fastq`

Where `file_R1.fastq` `file_R2.fastq` are the files provided by the Illumina sequencer.

The script will ask if you want to trim some bases at the beginning of the sequences and also at the end. In order to give an appropriate number in both cases, it is recommended first to run FastQC with the raw secuences (file_R1.fastq file_R2.fastq), check the output and then decide if you need to trim. 

## DEPENDENCIES ##

You need the following programs in your PATH:

-[Cutadapt](https://github.com/marcelm/cutadapt)

And if you want to merge the sequences:

-[flash](https://ccb.jhu.edu/software/FLASH/)

Finally, FastQC is optional

-[FastQC](http://www.bioinformatics.babraham.ac.uk/projects/fastqc)
