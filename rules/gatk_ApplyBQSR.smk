rule gatk_ApplyBQSR:
    input:
        bam = "aligned_reads/{sample}_sorted_mkdups.bam",
        recal = "aligned_reads/{sample}_recalibration_report.grp",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        bam = protected("aligned_reads/{sample}_recalibrated.bam")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads= expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        others= " --create-output-bam-md5 --add-output-sam-program-record --static-quantized-quals 10 --static-quantized-quals 20 --static-quantized-quals 30 --static-quantized-quals 40 --static-quantized-quals 50"
    log:
        "logs/gatk_ApplyBQSR/{sample}.log"
    benchmark:
        "benchmarks/gatk_ApplyBQSR/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Applying base quality score recalibration and producing a recalibrated BAM file for {input.bam}"
    shell:
        "gatk ApplyBQSR --java-options {params.maxmemory}  -I {input.bam} -bqsr {input.recal} {params.others} -R {input.refgenome} {params.padding} -O {output}   &> {log}"