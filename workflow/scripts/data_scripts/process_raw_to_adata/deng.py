import scanpy as sc
import pandas as pd
import anndata as ad
import numpy as np
import re
import os
import pathlib
import sys

def main(input_dir, output_file):
    input_file = os.path.join(input_dir, "deng_reads.tsv")  
    if not os.path.exists(input_file):
        raise FileNotFoundError(f"Input file not found: {input_file}")
    counts = pd.read_csv(input_file, sep='\t')
    counts.columns = counts.columns.str.replace('#', '', regex=False)
    labels_initial = [column.split('_')[0] for column in counts.iloc[:,1:].columns]
    embryo_number = [column.split('.')[0].split('_')[1] for column in counts.iloc[:,1:].columns]
    labels_merged = ['zygote' if lab in ["zy", "early2cell"] else 
            '2cell' if lab in ["mid2cell", "late2cell"] else 
            'blast' if lab in ["earlyblast", "midblast", "lateblast"] else lab for lab in labels_initial]
    obs = pd.DataFrame()
    var = pd.DataFrame()
    var['genes']= counts.Gene_symbol.values.astype('str')
    obs['sample'] = embryo_number
    obs['cell_labels']=labels_merged
    adata = ad.AnnData( X=counts.iloc[:,1:].values.T,
                                obs=obs,
                                var=var)
    print(f"Created AnnData object: {adata}. Saving processed data to: {output_file}")
    adata.write(output_file)
if __name__ == "__main__":
    # Command-line arguments: input_dir and output_file
    if len(sys.argv) != 4:
        sys.exit(1)
    input_dir = sys.argv[1]
    output_file = sys.argv[2]
    main(input_dir, output_file)