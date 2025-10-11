#!/bin/bash

OUTPUT_DIR=$1

mkdir -p "$OUTPUT_DIR/data"
wget -O "${OUTPUT_DIR}/data/data.tar" \
'http://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE45719&format=file'

tar -C "${OUTPUT_DIR}/data" -xvf "${OUTPUT_DIR}/data/data.tar"
gunzip ${OUTPUT_DIR}/data/*

# mkdir -p /work/Master_Project/raw_data/Deng/data
# wget -O /work/Master_Project/raw_data/Deng/data.tar 'http://www.ncbi.nlm.nih.gov/geo/download/?acc=GSE45719&format=file'

# # Extract the data into the specified folder and unzip
# tar -C /work/Master_Project/raw_data/Deng/data -xvf /work/Master_Project/raw_data/Deng/data.tar
# gunzip /work/Master_Project/raw_data/Deng/data/*
## raw reads


paste $(ls ${OUTPUT_DIR}/data/GSM111*_zy* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > \
${OUTPUT_DIR}/reads_zy.txt
for file in $(ls ${OUTPUT_DIR}/data/GSM111*_zy* | sort); do
    # Extract the number after "zy" in the filename
    number=$(echo "$file" | sed -n 's/.*_zy\([0-9]*\).*/\1/p')
    sample_name="zy_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_zy.txt
done
paste $(ls ${OUTPUT_DIR}/data/GSM111*_early2cell_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_early2cell.txt
for file in $(ls ${OUTPUT_DIR}/data/GSM111*_early2cell_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_early2cell_\([0-9]*\).*/\1/p')
    sample_name="early2cell_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_early2cell.txt
done
paste $(ls ${OUTPUT_DIR}/data/GSM111*_mid2cell_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_mid2cell.txt
for file in $(ls ${OUTPUT_DIR}/data/GSM111*_mid2cell_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_mid2cell_\([0-9]*\).*/\1/p')
    sample_name="mid2cell_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_mid2cell.txt
done
paste $(ls ${OUTPUT_DIR}/data/GSM111*_late2cell_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_late2cell.txt
for file in $(ls ${OUTPUT_DIR}/data/GSM111*_late2cell_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_late2cell_\([0-9]*\).*/\1/p')
    sample_name="late2cell_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_late2cell.txt
done
paste $(ls ${OUTPUT_DIR}/data/GSM111*_4cell_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_4cell.txt
for file in $(ls ${OUTPUT_DIR}/data/GSM111*_4cell_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_4cell_\([0-9]*\).*/\1/p')
    sample_name="4cell_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_4cell.txt
done
# 8cell files have a bit different notation
paste $(ls ${OUTPUT_DIR}/data/*_8cell_*-* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_8cell.txt
for file in $(ls ${OUTPUT_DIR}/data/*_8cell_*-* | sort); do
    number=$(echo "$file" | sed -n 's/.*_8cell_\([0-9]*\).*/\1/p')
    sample_name="8cell_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_8cell.txt
done
paste $(ls ${OUTPUT_DIR}/data/GSM111*_16cell_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_16cell.txt
for file in $(ls ${OUTPUT_DIR}/data/GSM111*_16cell_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_16cell_\([0-9]*\).*/\1/p')
    sample_name="16cell_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_16cell.txt
done

paste $(ls ${OUTPUT_DIR}/data/GSM111*_earlyblast_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_earlyblast.txt

for file in $(ls ${OUTPUT_DIR}/data/GSM111*_earlyblast_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_earlyblast_\([0-9]*\).*/\1/p')
    sample_name="earlyblast_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_earlyblast.txt
done

paste $(ls ${OUTPUT_DIR}/data/GSM111*_midblast_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_midblast.txt

for file in $(ls ${OUTPUT_DIR}/data/GSM111*_midblast_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_midblast_\([0-9]*\).*/\1/p')
    sample_name="midblast_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_midblast.txt
done

paste $(ls ${OUTPUT_DIR}/data/GSM111*_lateblast_* | sort) | \
awk '{for (i = 4; i <= NF; i += 6) printf ("%s%c", $i, i + 6 <= NF ? "\t" : "\n");}' > ${OUTPUT_DIR}/reads_lateblast.txt

for file in $(ls ${OUTPUT_DIR}/data/GSM111*_lateblast_* | sort); do
    number=$(echo "$file" | sed -n 's/.*_lateblast_\([0-9]*\).*/\1/p')
    sample_name="lateblast_${number}"
    sed -i "0,/reads/s//${sample_name}/" ${OUTPUT_DIR}/reads_lateblast.txt
done

awk -F"\t" '{if ($1) print $1}' ${OUTPUT_DIR}/data/GSM1112767_zy2_expression.txt > ${OUTPUT_DIR}/gene-names.txt

paste  ${OUTPUT_DIR}/reads_*.txt > ${OUTPUT_DIR}/deng.txt
paste ${OUTPUT_DIR}/gene-names.txt ${OUTPUT_DIR}/deng.txt > ${OUTPUT_DIR}/deng-reads.txt
#sed -i '1s/^#//' /work/Master_Project/raw_data/Deng/deng-reads.txt
