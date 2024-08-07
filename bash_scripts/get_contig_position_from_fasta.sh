contig_name="HRSCAF_7031"; #should not be the full header, should be the unique identificator of the contig
file_path="Zalophus.californianus__genome__2068.CSL-13399-Jaxy__Chicago.HiC__v2.2.fasta";
echo "Contig name is ${contig_name}";
echo " ";

seq=$(awk "/^>.*${contig_name}/{flag=1; next} /^>/{flag=0} flag" ${file_path} | tr -d '\n');

echo "The sequence of the contig itself";
echo $seq;
echo "---------------------------------";

echo "The length of the contig sequence";
echo ${#seq};
echo "---------------------------------";

echo "Get the nucleotide on the required position";
echo $seq | cut -c 934;
echo "---------------------------------";

echo "Get the nucleotide on the required range of positions";
echo $seq | cut -c 933-935;
echo "---------------------------------";
