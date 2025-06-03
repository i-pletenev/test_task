#!/usr/bin/env python3

import argparse
import logging
import os
import sys
from datetime import datetime
import pandas as pd
import pysam


# Настройка логгера с временными метками
logger = logging.getLogger()
logger.setLevel(logging.INFO)
formatter = logging.Formatter('[%(asctime)s] %(levelname)s: %(message)s', '%Y-%m-%d %H:%M:%S')
file_handler = logging.FileHandler('set_ref_alt.log', mode='w')
file_handler.setFormatter(formatter)
console_handler = logging.StreamHandler()
console_handler.setFormatter(formatter)
logger.addHandler(file_handler)
logger.addHandler(console_handler)


def parse_arguments():
    """
    Чтение аргументов
    """
    parser = argparse.ArgumentParser(
        description='Преобразует файл с колонками #CHROM, POS, ID, allele1, allele2 '
                    'в файл с колонками #CHROM, POS, ID, REF, ALT, определяя референсный и альтернативный аллели.'
    )

    parser.add_argument('--input', '-i', required=True, help='Путь к входному файлу')
    parser.add_argument('--output', '-o', required=True, help='Путь к выходному файлу')

    return parser.parse_args()


def is_valid_header(header):
    """
    Проверка первой строки
    """
    expected = ['#CHROM', 'POS', 'ID', 'allele1', 'allele2']
    return (header == expected).all()


def get_ref_allele(pos, chrom, fa):
    """
    Поиск референсного аллеля для данной позиции
    """
    try:
        base = fa.fetch(chrom, pos - 1, pos)
        return base.upper()
    except Exception as e:
        return f"ERR: {e}"
    

def get_alt_allele(row):
    """
    Выбор альтернативного аллеля из пары allele1, allele2
    """
    chrom, pos, allele1, allele2, ref = \
        row['#CHROM'], row['POS'], row['allele1'], row['allele2'], row['REF']
    if (allele1 == ref) and (allele2 != ref):
        return allele2
    elif (allele1 != ref) and (allele2 == ref):
        return allele1
    elif (allele1 == ref) and (allele2 == ref):
        logging.warning(f"Оба аллеля совпадают с референсным в позиции: {chrom}:{pos}")
        return "no alt"
    else:
        logging.warning(f"Оба аллеля ({allele1}, {allele2}) не совпадают с референсным ({ref}) в позиции {chrom}:{pos}")
        return "two alt"


def main():
    args = parse_arguments()

    logging.info('Начало обработки')
    
    # Проверка наличия входного файла
    if not os.path.isfile(args.input):
        logging.error(f'Входной файл не найден: {args.input}')
        sys.exit()

    try:
        # Чтение файла
        input_df = pd.read_csv(args.input, sep='\t', header=0)
        
        # Проверка первой строки
        header = input_df.columns
        if not is_valid_header(header):
            logging.error(f'Некорректный заголовок: {header}')
            sys.exit()
        
        # Поиск референсного аллеля в fasta файле
        chroms = input_df["#CHROM"].unique()
        for chrom in chroms:
            genome_path = f"sepChrs/{chrom}.fa"
            fa = pysam.FastaFile(genome_path)

            chrom_idx = input_df.loc[input_df['#CHROM'] == chrom].index
            input_df.loc[chrom_idx, 'REF'] = \
                input_df.loc[chrom_idx, 'POS'].apply(lambda pos: get_ref_allele(pos, chrom, fa))

            fa.close()
        
        # Выбор альтернативного аллеля из пары allele1, allele2
        input_df.loc[:, 'ALT'] = input_df.apply(get_alt_allele, axis=1)
        
        # Запись итогового файла
        input_df.to_csv(args.output, sep='\t', index=False, header=True)
        logging.info('Обработка завершена успешно')

    except Exception as e:
        logging.exception(f'Произошла ошибка: {e}')
        sys.exit()


if __name__ == '__main__':
    main()
