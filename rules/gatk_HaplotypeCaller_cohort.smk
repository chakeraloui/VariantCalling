rule gatk_HaplotypeCaller_cohort:
    input:
        bams = "aligned_reads/{sample}_mkdups_sorted_recalibrated.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        dbsnp = expand("{dbsnp}", dbsnp = config['dbSNP'])
    output:
        vcf = protected("aligned_reads/{sample}_raw_snps_indels_tmp.g.vcf")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        other = "-ERC GVCF    -G StandardAnnotation -G AS_StandardAnnotation -G StandardHCAnnotation   -GQB 10 -GQB 20 -GQB 30 -GQB 40 -GQB 50 -GQB 60 -GQB 70 -GQB 80 -GQB 90 "
    log:
        "logs/gatk_HaplotypeCaller_cohort/{sample}.log"
    benchmark:
        "benchmarks/gatk_HaplotypeCaller_cohort/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calling germline SNPs and indels via local re-assembly of haplotypes for {input.bams}"
    shell:
        "gatk  HaplotypeCaller --java-options {params.maxmemory} -I {input.bams} -R {input.refgenome} -D {input.dbsnp} -O {output.vcf} --tmp-dir {params.tdir} {params.padding} {params.intervals} {params.other} &> {log}"

       
