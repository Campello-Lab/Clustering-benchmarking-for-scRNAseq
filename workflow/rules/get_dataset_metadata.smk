rule profile_dataset:
    input:
        "results/benchmark_analysis/processed_normalized_adata/{dataset}.h5ad"

    output:
        "results/metadata/{dataset}.json"

    script:
        "../scripts/profile_dataset.py"


checkpoint datasets_profiled:
    input:
        expand(
            "results/metadata/{dataset}.json",
            dataset=cfg.get_subdata_names()
        )

    output:
        touch("results/metadata/.done")