rule gatk_CollectAlignmentSummaryMetrics:
    input:
        "aligned_reads/{sample}_recalibrated.bam"
    output:
        metrics ="aligned_reads/{sample}_alignment_metrics.txt"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR']
    log:
        "logs/gatk_aligne_reads/{sample}.log"
    benchmark:
        "benchmarks/gatk_aligne_reads/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Collecting Alignment from {input}"
    shell:
        "gatk CollectAlignmentSummaryMetrics --java-options {params.maxmemory} -R {input.refgenome} -I {input} -O {output.metrics}  --TMP_DIR {params.tdir} &> {log}"