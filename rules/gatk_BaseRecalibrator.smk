rule gatk_BaseRecalibrator:
    input:
        bams = "aligned_reads/{sample}_sorted_mkdups.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        report("aligned_reads/{sample}_recalibration_report.grp", caption = "aligned_reads/{sample}_recalibration.rst", category = "Base recalibration")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],
        threads = expand('"-XX:ParallelGCThreads = {threads}"', threads = config['THREADS']),
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        recalibration_resources = get_recal_resources_command
    log:
        "logs/gatk_BaseRecalibrator/{sample}.log"
    benchmark:
        "benchmarks/gatk_BaseRecalibrator/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Generating a recalibration table for {input.bams}"
    shell:
        "gatk  BaseRecalibrator  --java-options {params.maxmemory}  --tmp-dir {params.tdir}    -I {input.bams}  -R {input.refgenome}   {params.padding}  {params.recalibration_resources}  -O {output} &> {log}"