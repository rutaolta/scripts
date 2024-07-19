rm_out=GCA_009762305.2_mZalCal1.pri.v2_rm.out.gz;
cleaned_rm_out=GCA_009762305.2_mZalCal1.pri.v2_rm.csv;
chr=CM019820.2;
partial_rm_out=GCA_009762305.2_mZalCal1.pri.v2_rm.$chr.csv;
partial_withheader_rm_out=GCA_009762305.2_mZalCal1.pri.v2_rm.$chr.withheader.csv;

# change random space delimmeters to tab delimmeters in rm.out.gz file
zcat $rm_out | awk '{$1=$1; print}' OFS="\t" > $cleaned_rm_out;

# get data for specific chromosome
awk -v chr="$chr" '$5 == chr' $cleaned_rm_out > $partial_rm_out;

# or in one command to not generate additional heavy files
zcat $rm_out | awk '{$1=$1; print}' OFS="\t" | awk -v chr="$chr" '$5 == chr' > $partial_rm_out;

# add header to the new file
header="SW_score_ID\tperc_div\tperc_del\tperc_ins\tquery_sequence\tpos_in_query_begin\tpos_in_query_end\tin_query_left\tdirection\tmatching_repeat\trepeat_class\tpos_in_rep_begin\tpos_in_rep_end\tin_rep_left\tID";
{ echo -e "$header"; cat "$partial_rm_out"; } > "$partial_withheader_rm_out";

# get unique repeat classes
awk '{print $11}' $partial_rm_out | sort | uniq;
