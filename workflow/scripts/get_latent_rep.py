import scvi
#import cellxgene_census
import scanpy as sc

#census = cellxgene_census.open_soma(census_version = snakemake.params.version)
silver_data = sc.read_h5ad(str(snakemake.input.silver_standard))
model = snakemake.input.model

del silver_data.varm
silver_data.var["ensembl_id"] = silver_data.var.index
silver_data.obs["n_counts"] = silver_data.X.sum(axis=1)
silver_data.obs["joinid"] = list(range(silver_data.n_obs))
# initialize the batch to be unassigned. This could be any dummy value.
silver_data.obs["batch"] = "unassigned"

scvi.model.SCVI.prepare_query_anndata(silver_data, model)


vae_q = scvi.model.SCVI.load_query_data(
    silver_data,
    model,
)

# This allows for a simple forward pass
vae_q.is_trained = True
latent = vae_q.get_latent_representation()
silver_data.obsm["scvi"] = latent

# filter out missing features
silver_data = silver_data[:, silver_data.var["ensembl_id"].notnull().values].copy()
silver_data.var.set_index("ensembl_id", inplace=True)

silver_data.write(str(snakemake.output.adata_embedding))