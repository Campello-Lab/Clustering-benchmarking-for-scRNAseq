import cellxgene_census

cellxgene_census.download_source_h5ad(str(snakemake.params.dataset_id), to_path=str(snakemake.output.processed_file))