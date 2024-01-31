#!/bin/bash

for filename in $1/*.fastq.gz; do
    zcat $filename | head -n1 | cut -d ':' -f 1; echo $filename 
done
