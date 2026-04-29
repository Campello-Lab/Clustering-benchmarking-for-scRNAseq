import scanpy as sc 
import numpy as np
import scipy.sparse as spa
import matplotlib.pyplot as plt
import os

def preprocess_dataset(adata, input=snakemake.params.input_rep,  cell_label = snakemake.params.cell_label ):
    del adata.obsp
    del adata.obsm
    del adata.varm
    if adata.raw is not None:
        print('Found raw representation of counts, writing to anndata.X ....')
        adata.X = adata.raw.X
    adata.var_names_make_unique()    #just to make sure 
    if True in (np.unique(adata.var_names.str.startswith('MT-'))):
        adata.var['mt'] = adata.var_names.str.startswith('MT-')
        sc.pp.calculate_qc_metrics(adata, qc_vars=['mt'], percent_top=None, log1p=False, inplace=True)
        adata = adata[adata.obs.pct_counts_mt < 10, :]
    if len(adata.obs)>10000: #if number of cells is in tens of thousands
        print('Filtering Zheng dataset')
        sc.pp.filter_cells(adata, min_genes=1000, inplace=True)
    sc.pp.filter_cells(adata, min_genes=100, inplace=True)  #other than that procees with simple processing..
    sc.pp.filter_genes(adata, min_cells=(len(adata.obs)*0.1), inplace=True)
    adata.layers["counts"] = adata.X.copy()
    if (input == 'raw'):
        sc.pp.normalize_total(adata, target_sum=None, key_added='norm_factor')  #
        # If None, after normalization, each observation (cell) has a total count equal to the median of total counts for observations (cells) before normalization.
        #shifted logarithm
        #https://www.sc-best-practices.org/preprocessing_visualization/normalization.html
        sc.experimental.pp.highly_variable_genes(adata, n_top_genes=1000, layer='counts')
    else:
        sc.pp.log1p(adata, layer='counts')
        sc.pp.highly_variable_genes(adata,n_top_genes=1000, layer='counts') #this function expects log transformed data
    sc.pp.log1p(adata)  #this probably has to be there.....
    adata_p= adata[:, adata.var["highly_variable"]]
    if (spa.issparse(adata_p.X)):
        print('modify')
        #adata_p.X=adata_p.X.toarray()
        adata_p.layers["counts"] =adata_p.X.toarray()
        adata_p.X = adata_p.layers["counts"]
    return adata_p




processed = preprocess_dataset(sc.read(str(snakemake.input)))
processed.write(str(snakemake.output.processing))