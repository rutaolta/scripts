#!/bin/bash

x_map=$(samtools idxstats $1 | grep "$2\s" | cut -f 3)
x_len=$(samtools idxstats $1 | grep "$2\s" | cut -f 2)
x_cov=$(echo "scale=3; ${x_map}/${x_len}" | bc)

y_map=$(samtools idxstats $1 | grep "$3\s" | cut -f 3)
y_len=$(samtools idxstats $1 | grep "$3\s" | cut -f 2)
y_cov=$(echo "scale=3; ${y_map}/${y_len}" | bc)

ratio=$(echo "scale=2; ${x_cov}/${y_cov}" | bc)
echo $ratio

# $ratio > 4.00 --> female, else male