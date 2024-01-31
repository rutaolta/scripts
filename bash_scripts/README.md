In current repository some useful bioinformatic scripts are collected

### Find instrument/sequencer ID from .fastq/.fq header

Sometimes before uploading data to NCBI you don't know the instrument ID which is required by NCBI.
You can try to identify it with the header in fastq file.

### PSMC analysis

The whole pipeline to get PSMC plot from fasta and bam.
MAVR depository is used, stored in https://github.com/mahajrod/MAVR.

### Check sex from alignment

Script checks the sex of sample based on alignment.
X and Y chromosomes should be recognized.
Usage:
```bash
chmod +x check_sex_from_bams.sh
./check_sex_from_bams.sh <path_to_the_bam_file> <header_for_X_chromosome> <header_for_Y_chromosome>
```
Example:
./check_sex_from_bams.sh /data/ZalCal.bam CM019819.2 CM019820.2