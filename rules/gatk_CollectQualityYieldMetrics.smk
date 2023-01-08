rule gatk_CollectQualityYieldMetrics:
    input:
        ubam = "unmapped_bam/{sample}_unmapped.bam"
    output:
        yield_metrics = "aligned_reads/{sample}_unmapped_quality_yield_metrics"
    
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY'])
    log:
        "logs/CollectQualityYieldMetrics/{sample}.log"
    benchmark:
        "benchmarks/CollectQualityYieldMetrics/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calling germline SNPs and indels via local re-assembly of haplotypes for {input.bams}"
    shell:
        # Collect sequencing yield quality metrics
        "java -Xms2000m -Xmx3000m -jar ../tools/picard.jar     CollectQualityYieldMetrics    INPUT={input.ubam}  OQ=true     OUTPUT={output.yield_metrics}&> {log}"