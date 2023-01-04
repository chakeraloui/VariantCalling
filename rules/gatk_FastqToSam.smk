rule FastqToSam:
    input:
        fastq1="../test/{sample}_R1.fastq.gz",
        fastq2= "../test/{sample}_R2.fastq.gz" # to adapt
    output:
        ubam = temp("unmapped_bams/{sample}_unmapped.bam")
    params:
        run_date="2023-01-01",
        readgroup_name="{sample}_rg1",
        sample_name="{sample}"    
    log:
        "logs/fastqtosam/{sample}.log"
    benchmark:
        "benchmarks/fastqtosam/{sample}.tsv"
    threads:  config['THREADS']
    conda:
        "./envs/fastqc.yaml"
    message:
        "Converting {params.sample_name} FASTQ file to an unaligned BAM  ({output.ubam})"
    shell:
        """ gatk --java-options "-Xmx10g " \
        FastqToSam \
        --FASTQ {input.fastq1} \
        --FASTQ2 {input.fastq2} \
        --OUTPUT {output.ubam} \
        --READ_GROUP_NAME {params.readgroup_name} \
        --SAMPLE_NAME {params.sample_name} \
        --LIBRARY_NAME Solexa-NA12878 \
        --PLATFORM_UNIT H06HDADXX130110.2.ATCACGAT \
        --RUN_DATE {params.run_date} \
        --PLATFORM illumina \
        --SEQUENCING_CENTER BI \
         &>{log} """
