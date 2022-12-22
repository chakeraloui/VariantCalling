rule multiqc:
    input:
        expand(["aligned_reads/{sample}_R1_fastqc.zip", "aligned_reads/{sample}_R2_fastqc.zip"], sample = SAMPLES)
    output:
        report("aligned_reads/multiqc_report.html", caption = "aligned_reads/{sample}_quality_checks.rst", category = "Quality checks")
    conda:
        "../envs/multiqc.yaml"
    log:
        "logs/multiqc/multiqc.log"
    message:
        "Compiling a HTML report for quality control checks on raw sequence data"
    shell:
        "multiqc {input} -o aligned_reads/ &> {log}"