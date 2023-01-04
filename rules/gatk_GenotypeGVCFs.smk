rule gatk_GenotypeGVCFs:
    input:
        gvcf = "aligned_reads/{family}_raw_snps_indels_tmp_combined.g.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        protected("aligned_reads/{family}_raw_snps_indels.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        other = "-G StandardAnnotation -G AS_StandardAnnotation  --allow-old-rms-mapping-quality-annotation-data  --merge-input-intervals "
    log:
        "logs/gatk_GenotypeGVCFs/{family}.log"
    benchmark:
        "benchmarks/gatk_GenotypeGVCFs/{family}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Performing joint genotyping on one or more samples pre-called with HaplotypeCaller for {input.gvcf}"
    shell:
        """ gatk GenotypeGVCFs --java-options {params.maxmemory} -R {input.refgenome} \
        -V {input.gvcf} -O {output} {params.padding} {params.intervals} {params.other} &> {log}"""
