
import scanpy as sc
import pandas as pd
import anndata as ad
import numpy as np
import re
import os
import pathlib
import sys


def main(input_dir, output_file):
    counts_file = os.path.join(input_dir, "goolam_counts.tsv")  # Assuming the file is named `data.txt`
    metadata_file = os.path.join(input_dir, "goolam_metadata.txt") 
    if any(not os.path.exists(file) for file in [counts_file, metadata_file]):
        raise FileNotFoundError(f"Missing file(s): {[file for file in [counts_file, metadata_file] if not os.path.exists(file)]}")
    counts = pd.read_csv(counts_file, sep='\t')
    metadata = pd.read_csv(metadata_file, sep='\t')

    labels = counts.columns.values
    cell_types = []
    for i in range(len(labels)):
        if '4cell' in labels[i]:
            cell_types.append('4cell')
        elif '8cell' in labels[i]:
            cell_types.append('8cell')
        elif '16cell' in labels[i]:
            cell_types.append('16cell')
        elif '32cell' in labels[i]:
            cell_types.append('blast')
        elif '2cell' in labels[i]:
            cell_types.append('2cell')
    obs = pd.DataFrame()
    var = pd.DataFrame()
    var['genes']= counts.index.values
    obs['sample'] = counts.columns.values
    obs['cell_labels']=cell_types
    adata = ad.AnnData( X=counts.values.T,
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