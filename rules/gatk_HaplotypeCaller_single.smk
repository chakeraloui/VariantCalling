rule gatk_HaplotypeCaller_single:
    input:
        bams = "aligned_reads/{sample}_recalibrated.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        dbsnp = expand("{dbsnp}", dbsnp = config['dbSNP'])
    output:
        protected("aligned_reads/{sample}_raw_snps_indels.vcf")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        threads = expand('"-XX:ParallelGCThreads={threads}"', threads = config['THREADS']),
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command
    log:
        "logs/gatk_HaplotypeCaller_single/{sample}.log"
    benchmark:
        "benchmarks/gatk_HaplotypeCaller_single/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calling germline SNPs and indels via local re-assembly of haplotypes for {input.bams}"
    shell:
        "gatk HaplotypeCaller --java-options {params.maxmemory}  -I {input.bams} -R {input.refgenome} -D {input.dbsnp} -O {output} --tmp-dir {params.tdir} {params.padding}  -ERC GVCF &> {log}"