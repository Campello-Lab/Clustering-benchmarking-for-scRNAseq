import json
import math
import scanpy as sc
from pathlib import Path

# Snakemake variables
input_file = snakemake.input[0]
output_file = snakemake.output[0]

# Config parameters
neighbors_cfg = snakemake.config["GRAPH_GENERATION"]["neighbors"]

neighbor_start = neighbors_cfg["start"]
neighbor_end = neighbors_cfg["end"]
neighbor_step = neighbors_cfg["step"]

# Load dataset
adata = sc.read_h5ad(input_file)

n_cells = adata.n_obs

print(n_cells)

# Adaptive neighbor determination
if n_cells < neighbor_end + 1:
    max_neighbors = math.ceil(n_cells - 0.1 * n_cells)
else:
    max_neighbors = neighbor_end

neighbors = list(
    range(
        neighbor_start,
        max_neighbors + 1,
        neighbor_step
    )
)

# Metadata dictionary
metadata = {
    "n_cells": int(n_cells),
    "neighbors": neighbors
}

# Save JSON
Path(output_file).parent.mkdir(parents=True, exist_ok=True)

with open(output_file, "w") as f:
    json.dump(metadata, f, indent=2)