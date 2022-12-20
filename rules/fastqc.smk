rule fastqc:
    input:
        ["../test/{sample}_R1.fastq.gz", "../test/{sample}_R2.fastq.gz"] # to adapt
    output:
        html = ["aligned_reads/{sample}_R1_fastqc.html", "aligned_reads/{sample}_R2_fastqc.html"],
        zip = ["./aligned_reads/{sample}_R1_fastqc.zip", "./aligned_reads/{sample}_R2_fastqc.zip"]
    log:
        "logs/fastqc/{sample}.log"
    benchmark:
        "benchmarks/fastqc/{sample}.tsv"
    threads:  config['THREADS']
    conda:
        "./envs/fastqc.yaml"
    message:
        "Undertaking quality control checks on raw sequence data for {input}"
    shell:
        "fastqc {input} -o aligned_reads/ -t {threads} &> {log}"