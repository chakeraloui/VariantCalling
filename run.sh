bin/bash -x

snakemake \
--cores 2 \
--resources mem_mb=2000 \
--use-conda \
--conda-frontend mamba \
--latency-wait 120 \
--configfile ./config/config.yaml
