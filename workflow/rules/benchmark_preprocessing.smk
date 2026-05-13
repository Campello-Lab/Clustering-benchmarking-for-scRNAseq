rule preprocess_normalize_adata:
    input:
        processed_adata="data/processed_adata/{dataset}.h5ad"
    output:
        processing="results/benchmark_analysis/processed_normalized_adata/{dataset}.h5ad"
    params:
        input_rep=lambda wildcards: cfg.get_from_dataset(wildcards.dataset, key='data_type'),
        cell_label=lambda wildcards: cfg.get_from_dataset(wildcards.dataset, key='cell_labels'),
    conda: "../envs/benchmark_process_normalize.yaml"
    script: "../scripts/preprocess_normalize.py"