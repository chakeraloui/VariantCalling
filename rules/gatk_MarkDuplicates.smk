rule gatk_MarkDuplicates:
    input:
        bams = "aligned_reads/{sample}_sorted.bam"
    output:
        bam = temp("aligned_reads/{sample}_sorted_mkdups.bam"),
        metrics = "aligned_reads/{sample}_sorted_mkdups_metrics.txt"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR']
    log:
        "logs/gatk_MarkDuplicates/{sample}.log"
    benchmark:
        "benchmarks/gatk_MarkDuplicates/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Locating and tagging duplicate reads in {input}"
    shell:
        "gatk MarkDuplicatesSpark   -I {input.bams}   -O {output.bam} -M {output.metrics}  --spark-runner LOCAL --spark-master 'local[4]'   --conf spark.driver.extraJavaOptions=-Xss2m --conf spark.executor.extraJavaOptions=-Xss2m &> {log}"
        