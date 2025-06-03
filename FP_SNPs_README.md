# Препроцессинг данных

## Препроцессинг таблицы с аллелями

Конвертация исходной таблицы `FP_SNPs.txt` в VCF-like таблицу `FP_SNPs_10k_GB38_twoAllelsFormat.tsv`

```bash
INPUT_SNP="FP_SNPs.txt"
OUTPUT_SNP="FP_SNPs_10k_GB38_twoAllelsFormat.tsv"
awk -F'\t' 'NR==1 {print "#CHROM", "POS", "ID", "allele1", "allele2"; next} $2 != 23 {printf "chr%s\t%s\trs%s\t%s\t%s\n", $2, $4, $1, $5, $6}' OFS='\t' ${INPUT_SNP} > ${OUTPUT_SNP}
```

## Препроцессинг fasta

Код оставляет хромосомы 1-22, записывает их в разные файлы и индексирует

```bash
#!/bin/bash

INPUT_FASTA="GRCh38.d1.vd1.fa"
OUTPUT_DIR="sepChrs"

mkdir -p "${OUTPUT_DIR}"

awk -v outdir="${OUTPUT_DIR}" '
  BEGIN {
    for (i = 1; i <= 22; i++) keep["chr" i] = 1
  }

  /^>/ {
    split($1, h, ">") 
    chrom = h[2]

    if (!(chrom in keep)) {
      file = ""
      next
    }

    if (file) close(file)
    file = outdir "/" chrom ".fa"
    print $0 > file
    next
  }

  file {
    print $0 > file
  }
' "${INPUT_FASTA}"

# Index each chromosome FASTA
for FA in "$OUTPUT_DIR"/*.fa; do
    samtools faidx "$FA"
done
```

# Определение референсной и альтернативной аллели

Скрипт `set_ref_alt.py` берёт на вход файл `FP_SNPs_10k_GB38_twoAllelsFormat.tsv` и конвертирует его в файл `FP_SNPs_10k_GB38_ref_alt_format.tsv`, в котором определено, какая из двух аллелей является референсной, а какая - альтернативной. Сообщения скрипта выводятся в консоль, а также записываются в файл `set_ref_alt.log`.

## Запуск скрипта

Команда для запуска скрипта:

```bash
docker run --rm -it \
  -v /mnt/data/ref/GRCh38.d1.vd1_mainChr/sepChrs/:/ref/GRCh38.d1.vd1_mainChr/sepChrs/ \
  -v "$PWD":/work \
  -w /work bio-soft \
  python3 set_ref_alt.py --input FP_SNPs_10k_GB38_twoAllelsFormat.tsv --output FP_SNPs_10k_GB38_ref_alt_format.tsv
```

## Результаты

В результате работы скрипта референсный и альтернативный аллели были успешно определены для всех позиций, кроме девяти, где оба аллеля не совпали с референсным:

```
[2025-06-03 12:18:31] INFO: Начало обработки
[2025-06-03 12:18:31] WARNING: Оба аллеля (T, C) не совпадают с референсным (G) в позиции chr1:145899155
[2025-06-03 12:18:31] WARNING: Оба аллеля (T, C) не совпадают с референсным (G) в позиции chr10:47420743
[2025-06-03 12:18:31] WARNING: Оба аллеля (C, A) не совпадают с референсным (T) в позиции chr10:47320207
[2025-06-03 12:18:31] WARNING: Оба аллеля (T, C) не совпадают с референсным (A) в позиции chr10:47268342
[2025-06-03 12:18:31] WARNING: Оба аллеля (G, A) не совпадают с референсным (T) в позиции chr10:47099482
[2025-06-03 12:18:31] WARNING: Оба аллеля (A, G) не совпадают с референсным (C) в позиции chr10:46031829
[2025-06-03 12:18:31] WARNING: Оба аллеля (C, T) не совпадают с референсным (G) в позиции chr11:54678670
[2025-06-03 12:18:31] WARNING: Оба аллеля (T, C) не совпадают с референсным (G) в позиции chr15:22907410
[2025-06-03 12:18:31] WARNING: Оба аллеля (T, C) не совпадают с референсным (A) в позиции chr15:22832212
[2025-06-03 12:18:31] INFO: Обработка завершена успешно
```

В получившемся файле в этих строках в колонке ALT указано значение "two alt".

