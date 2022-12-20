rule multiqc:
    input:
        fastqc = expand(["aligned_reads/{sample}_R1_fastqc.zip", "aligned_reads/{sample}_R2_fastqc.zip"], sample = SAMPLES),
        trimming1 = expand("aligned_reads/trimmed/{sample}_1.fastq.gz_trimming_report.txt", sample = SAMPLES),
        trimming2 = expand("aligned_reads/trimmed/{sample}_2.fastq.gz_trimming_report.txt", sample = SAMPLES)
    output:
        report("aligned_reads/multiqc_report.html", caption = "aligned_reads/quality_checks.rst", category = "Quality checks")
    conda:
        "../envs/multiqc.yaml"
    log:
        "logs/multiqc/multiqc.log"
    message:
        "Compiling a HTML report for quality control checks on raw sequence data"
    shell:
        "multiqc {input.fastqc} {input.trimming1} {input.trimming2} -o aligned_reads/ &> {log}"
