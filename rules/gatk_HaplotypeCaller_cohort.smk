rule gatk_HaplotypeCaller_cohort:
    input:
        bams = "aligned_reads/{sample}_recalibrated.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        dbsnp = expand("{dbsnp}", dbsnp = config['dbSNP'])
    output:
        vcf = temp("aligned_reads/{sample}_raw_snps_indels_tmp.g.vcf"),
        index = temp("aligned_reads/{sample}_raw_snps_indels_tmp.g.vcf.idx")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        other = "-ERC GVCF  -contamination 0   -G StandardAnnotation -G StandardHCAnnotation  -new-qual -GQB 10 -GQB 20 -GQB 30 -GQB 40 -GQB 50 -GQB 60 -GQB 70 -GQB 80 -GQB 90 "
    log:
        "logs/gatk_HaplotypeCaller_cohort/{sample}.log"
    benchmark:
        "benchmarks/gatk_HaplotypeCaller_cohort/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calling germline SNPs and indels via local re-assembly of haplotypes for {input.bams}"
    shell:
        "gatk HaplotypeCaller --java-options {params.maxmemory} -I {input.bams} -R {input.refgenome} -D {input.dbsnp} -O {output.vcf} --tmp-dir {params.tdir} {params.padding} {params.intervals} {params.other} &> {log}"