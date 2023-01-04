rule gatk_MarkDuplicates:
    input:
        bams = "aligned_reads/{sample}_sorted.bam"
    output:
        bam = temp("aligned_reads/{sample}_sorted_mkdups.bam"),
        metrics = "aligned_reads/{sample}_sorted_mkdups_metrics.txt"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],
        mapped_bam="{sample}_mapped_bam",
        out="aligned_reads",
        others= " --read-validation-stringency SILENT  --optical-duplicate-pixel-distance 2500 --treat-unsorted-as-querygroup-ordered --create-output-bam-index false ",
        spark= "--conf spark.local.dir=tdir --spark-runner LOCAL --spark-master 'local[10]'   --conf spark.driver.extraJavaOptions=-Xss512m --conf spark.executor.extraJavaOptions=-Xss512m --conf 'spark.kryo.referenceTracking=false'"   
    log:
        "logs/gatk_MarkDuplicates/{sample}.log"
    benchmark:
        "benchmarks/gatk_MarkDuplicates/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Locating and tagging duplicate reads in {input}"
    shell:
        """ gatk MarkDuplicatesSpark   -I {input.bams}   -O {output.bam} -M {output.metrics} {params.others} {params.spark}&> {log}"""      
