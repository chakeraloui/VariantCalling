




grep -vE "^@" exome_calling_regions.v1.interval_list |   awk -v OFS='\t' '$2=$2-1' |  bedtools intersect -c -a Homo_sapiens_assembly38.contam.bed -b -  cut -f6 > target_overlap_counts.txt