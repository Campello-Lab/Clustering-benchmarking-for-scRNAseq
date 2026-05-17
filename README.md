
#  Environment Setup

To get started, first create the environment using `conda` or `mamba`. This will install `snakemake`, `snakedeploy` and a version of `scanpy` that is compatible with the workflow. Note that `anndata` is pinned to an older version to ensure compatibility with the selected scanpy version.

```bash
mamba create -c conda-forge -c bioconda --name snakemake_base snakemake snakedeploy scanpy=1.10.2 anndata=0.10.2
```
Activate the environment.
```bash
mamba activate snakemake_base
```


# Use the workflow (clone repository)
```bash
git clone https://github.com/Campello-Lab/Clustering-benchmarking-for-scRNAseq
cd Clustering-benchmarking-for-scRNAseq
```

   
## Configure Workflow:
Configuration file `config/config.yaml` contains configuration that will enable reproduction of the benchmarking performed in the paper. Edit `config/config.yaml` to adjust settings. You can comment out datasets to run the workflow on a smaller collection.

# Running the workflow

## Option A: Run Entire Workflow (Including Data Download)

```bash
snakemake --cores all --sdm conda
```

# Output Structure

## `data/raw_data/`

Original dataset files downloaded from the sources provided by the dataset authors.

Examples include:
- matrix files
- metadata tables
- raw count matrices

---

## `data/processed_adata/`

Datasets converted into standardized `AnnData` (`.h5ad`) format.

These files contain:
- raw count matrices
- cell metadata
- gene metadata

No normalization or feature selection has been applied at this stage.

---

## `results/benchmark_analysis/processed_normalized_adata/`

Preprocessed and normalized `AnnData` objects used for benchmarking.

This folder contain files after application of:
- preprocessing steps
- selection of 1,000 highly variable genes (HVGs)

---

After preprocessing is completed, the workflow reevaluates the DAG based on the selected algorithms and hyperparameter combinations specified in `config.yaml`.

# The resulting benchmarking outputs are stored in:

---

## `results/benchmark_analysis/pairwise_similarity/`

Pairwise similarity matrices stored in:

```python
adata.obsp["distances_full"]
```

---

## `results/benchmark_analysis/graphs/`

k-nearest neighbor (kNN) graphs used for clustering.

Stored in:
```python
adata.obsp["distances"]
adata.obsp["connectivities"]
```
where:
- `distances` contains graph distances
- `connectivities` contains edge weights

---

## `results/benchmark_analysis/clustering/`

Clustering assignments for all evaluated hyperparameter combinations.

Cluster labels are stored in:

```python
adata.obs
```

with keys formatted as:

```python
<quality_function>_<resolution>
```

Example:

```python
adata.obs["CPMVertexPartition_0.002"]
```

---

## `results/benchmark_analysis/evaluation/`

Evaluation results for all clustering partitions across multiple clustering evaluation measures.

---


## Option B: Skipping Data Download 


### To avoid rerunning raw data download and conversion steps, download the prepared `AnnData` (`.h5ad`) files from [Zenodo](https://zenodo.org/records/20157144).
----

These files already contain raw count matrices and metadata in standardized `AnnData` format, but have **not** been normalized, filtered, or otherwise preprocessed for clustering.


1. Download and extract `processed_adata.zip` from [Zenodo](https://zenodo.org/records/20157144).    
2. Place it into your project working directory under:

```
data/processed_adata/
```


# 📫 Contact

For questions or support, please open an issue or contact: `alszm@imada.sdu.dk`.


