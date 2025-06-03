# Data preprocessing

```bash
INPUT_SNP="GrafPkg/data/FP_SNPs.txt"
OUTPUT_SNP="FP_SNPs_10k_GB38_twoAllelsFormat.tsv"
awk -F'\t' 'NR==1 {print "#CHROM", "POS", "ID", "allele1", "allele2"; next} $2 != 23 {printf "chr%s\t%s\trs%s\t%s\t%s\n", $2, $4, $1, $5, $6}' OFS='\t' ${INPUT_SNP} > ${OUTPUT_SNP}
```
