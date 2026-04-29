import scanpy as sc 
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import adjusted_rand_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score
from pathlib import Path
import joblib
import json
import numpy as np



train_emb = sc.read_h5ad(str(snakemake.input.ref_embedding))
adata_latent = sc.read_h5ad(str(snakemake.input.adata_embedding))
adata_orig = sc.read_h5ad(str(snakemake.input.orig_adata))

dataset = str(snakemake.wildcards.dataset)

rfc = RandomForestClassifier(random_state=42)
cv_scores = cross_val_score(rfc, train_emb.obsm["scvi"], train_emb.obs["cell_type"], cv=10, n_jobs=-1)
rfc.fit(train_emb.obsm["scvi"], train_emb.obs["cell_type"])

model_dir = Path(f"resources/trained_classification_models")
model_dir.mkdir(parents=True, exist_ok=True)
joblib.dump(rfc, model_dir / f"{dataset}_rf_model.joblib")

cv_result = {
        "dataset": dataset,
        "cv_scores": cv_scores.tolist(),         # fold-wise scores
        "mean_cv_accuracy": float(np.mean(cv_scores)),
        "std_cv_accuracy": float(np.std(cv_scores))
    }


with open(model_dir / f"{dataset}_cv_results.json", "w") as f:
    json.dump(cv_result, f, indent=4)

adata_orig.obs["predicted_cell_type"] = rfc.predict(adata_latent.obsm["scvi"])


adata_orig.write(snakemake.output.new_labels)

