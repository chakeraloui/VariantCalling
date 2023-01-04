rule SamToFastq:
    input:
        ubam="unmapped_bams/{sample}_unmapped.bam"
        
    output:
        fastq1 = temp("unmapped_bams/{sample}_R1.fastq.gz"),
        fastq2 = temp("unmapped_bams/{sample}_R2.fastq.gz"),
        quality_yield_metrics="unmapped_bams/{sample}.quality_yield_metrics"
    params:
         
    log:
        "logs/fastqtosam/{sample}.log"
    benchmark:
        "benchmarks/fastqtosam/{sample}.tsv"
    threads:  config['THREADS']
    conda:
        "./envs/fastqc.yaml"
    message:
        "Converting {input.ubam} file to FASTQ."
    shell:
        """java -Xms1g -Xmx10g -jar ../tools/picard.jar \
        SamToFastq \
        --INPUT {input.ubam} \
        --FASTQ {output.fastq1} \
        --SECOND_END_FASTQ {output.fastq2} \
        -NON_PF true && \
        java -Xms2000m -Xmx3000m -jar ../tools/picard.jar \
        CollectQualityYieldMetrics \
        INPUT={output.ubam}\
        OQ=true \
        OUTPUT={output.quality_yield_metrics} &>{log}"""
