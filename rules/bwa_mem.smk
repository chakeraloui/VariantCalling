rule bwa_mem:
    input:
        fastq = get_input_fastq,
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output: 
        temp("./aligned_reads/{sample}_sorted.bam")
    params:
        readgroup = "'@RG\\tID:{sample}_rg1\\tLB:lib1\\tPL:bar\\tSM:{sample}\\tPU:{sample}_rg1'",
        #readgroup =  "'@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'" ,
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        sortsam = "--MAX_RECORDS_IN_RAM=400000 --SORT_ORDER=coordinate -I=/dev/stdin",
        tdir = expand("{tdir}", tdir = config['TEMPDIR'])
    log:
        "logs/bwa_mem/{sample}.log"
    benchmark:
        "benchmarks/bwa_mem/{sample}.tsv"
    conda:
        "../envs/bwa.yaml"
    threads: config['THREADS']
    message:
        "Mapping sequences against a reference human genome with BWA-MEM for {input.fastq}"
    shell:
         "bwa mem -M -t {threads} -K 10000000 -R {params.readgroup} {input.refgenome} {input.fastq} | gatk SortSam --java-options {params.maxmemory} {params.sortsam} -O={output} --TMP_DIR={params.tdir} &> {log}"
       