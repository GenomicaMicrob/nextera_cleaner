# nextera_cleaner
Script to clean Illumina pair-end sequences produced with the Nextera kit. Bases below Q30, Ns, and Nextera adapters are removed. Bases can also be removed at the beginning and end of each sequence. At the end, clean files can be analyzed with FastQC.

Dependencies

You need the following programs in your PATH:

Trim_galore!

FastQC

FASTX-Toolkit
