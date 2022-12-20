rule trim_galore_pe:
    input:
        ["../test/{sample}_R1.fastq.gz", "../test/{sample}_R2.fastq.gz"]
    output:
        temp("aligned_reads/trimmed/{sample}_1_val_1.fq.gz"),
        "aligned_reads/trimmed/{sample}_1.fastq.gz_trimming_report.txt",
        temp("aligned_reads/trimmed/{sample}_2_val_2.fq.gz"),
        "aligned_reads/trimmed/{sample}_2.fastq.gz_trimming_report.txt"
    params:
        adapters = config['TRIMMING']['ADAPTERS'],
        threads = config['THREADS'],
        other = "-q 20 --paired"
    log:
        "logs/trim_galore_pe/{sample}.log"
    benchmark:
        "benchmarks/trim_galore_pe/{sample}.tsv"
    conda:
        "../envs/trim_galore.yaml"
    threads: config['THREADS']
    message:
        "Applying quality and adapter trimming to input fastq files: {input}"
    shell:
        "trim_galore {input} -o aligned_reads/trimmed/ {params.adapters} {params.other} -j {threads} &> {log}"
