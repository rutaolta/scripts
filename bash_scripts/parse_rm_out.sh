rm_out=GCA_009762305.2_mZalCal1.pri.v2_rm.out.gz;
cleaned_rm_out=GCA_009762305.2_mZalCal1.pri.v2_rm.csv;
chr=CM019820.2;
partial_rm_out=GCA_009762305.2_mZalCal1.pri.v2_rm.$chr.csv;

# change random space delimmeters to tab delimmeters in rm.out.gz file
zcat $rm_out | awk '{$1=$1; print}' OFS="\t" > $cleaned_rm_out;

# get data for specific chromosome
awk -v chr="$chr" '$5 == chr' $cleaned_rm_out > $partial_rm_out;

# or in one command to not generate additional heavy files
zcat $rm_out | awk '{$1=$1; print}' OFS="\t" | awk -v chr="$chr" '$5 == chr' > $partial_rm_out;

