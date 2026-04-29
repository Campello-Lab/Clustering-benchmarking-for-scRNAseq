import cellxgene_census

census = cellxgene_census.open_soma(census_version = snakemake.params.version)

# Exclude datasets that will be used as a query (were downloaded from cellxgene)
dataset_ids = list(snakemake.params.dataset_ids.values())
tissue = [str(snakemake.wildcards.tissue)]
organism = str(snakemake.wildcards.organism)

# Exclude datasets that will be used as a query (were downloaded from cellxgene)
# 1. https://cellxgene.cziscience.com/e/1fe63353-9e75-4824-aa30-ed8d84be748c.cxg/   #TabulaMurisHeart

# dataset_ids = [
#     "1fe63353-9e75-4824-aa30-ed8d84be748c"
# ]


adata_census = cellxgene_census.get_anndata(
    census=census,
    measurement_name="RNA",
    organism=organism,
    obs_value_filter=f"dataset_id not in {dataset_ids} and tissue in {tissue}",
    obs_embeddings=["scvi"],
)
adata_census.var.set_index("feature_id", inplace=True)

adata_census.write(snakemake.output.ref_embedding)