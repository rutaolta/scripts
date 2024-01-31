In current repository some useful bioinformatic scripts are collected

### Mini quast

Script split fasta and gather all necessary information for preliminary evaluation of the fasta file (lenght of the whole genome, scaffold lenghts, the maximum scaffold length, scaffolds count, GC content, N count, N50, L50, NG50).

Example of usage *mini_quast.py* is shown in *test_mini_quast.ipynb*.

### Find hypervariable sites

Script searching for hypervariable sites by settings:

- path: relative or absolute path to fasta with sequencies of several samples

- count_boundary: if there are more unique nucleotides in site then site will be marked as hypervariable (*default=2*)

- frequency_boundary: if frequency of any unique nucleotide in site  is higher then site will be marked as hypervariable (*default=0.1*)

Example of usage *hypervariable_sites.py* is shown in *test_hypervariable_sites.ipynb*.
