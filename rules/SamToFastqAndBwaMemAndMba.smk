rule SamToFastqAndBwaMemAndMba:
    input:
        ubam = "unmapped_bams/{sample}_unmapped.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output: 
        bam ="aligned_reads/{sample}_aligned.unsorted.bam"
    params:
        readgroup = "'@RG\\tID:{sample}_rg1\\tLB:lib1\\tPL:bar\\tSM:{sample}\\tPU:{sample}_rg1'",
        #readgroup =  "'@RG\tID:{sample}\tPL:ILLUMINA\tSM:{sample}'" ,
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        sortsam = "--INPUT /dev/stdin --SORT_ORDER coordinate --MAX_RECORDS_IN_RAM 400000  ",
        tdir = expand("{tdir}", tdir = config['TEMPDIR']),
        bwa_commandline="bwa mem -K 100000000 -p -v 3 -t 6 -Y {input.refgenome}"
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
         """java -Xms1000m -Xmx1000m -jar ../tools/picard.jar SamToFastq   INPUT={input.ubam} FASTQ=/dev/stdout    INTERLEAVE=true  NON_PF=true |      bwa mem -M -t {threads} -K 10000000 {input.refgenome} /dev/stdin - 2> >(tee {sample}.bwa.stderr.log >&2) | \
         java -Dsamjdk.compression_level=~{compression_level} -Xms1000m -Xmx1000m -jar /usr/gitc/picard.jar \
         MergeBamAlignment \
         VALIDATION_STRINGENCY=SILENT \
         EXPECTED_ORIENTATIONS=FR \
         ATTRIBUTES_TO_RETAIN=X0 \
         ATTRIBUTES_TO_REMOVE=NM \
         ATTRIBUTES_TO_REMOVE=MD \
         ALIGNED_BAM=/dev/stdin \
         UNMAPPED_BAM={input.ubam} \
         OUTPUT=~{output.bam} \
         REFERENCE_SEQUENCE={input.refgenome} \
         SORT_ORDER="unsorted" \
         IS_BISULFITE_SEQUENCE=false \
         ALIGNED_READS_ONLY=false \
         CLIP_ADAPTERS=false \
         CLIP_OVERLAPPING_READS=true \
         CLIP_OVERLAPPING_READS_OPERATOR=H \
         MAX_RECORDS_IN_RAM=2000000 \
         ADD_MATE_CIGAR=true \
         MAX_INSERTIONS_OR_DELETIONS=-1 \
         PRIMARY_ALIGNMENT_STRATEGY=MostDistant \
         PROGRAM_RECORD_ID="bwamem" \
         PROGRAM_GROUP_VERSION="${BWA_VERSION}" \
         PROGRAM_GROUP_COMMAND_LINE="{params.bwa_commandline}" \
         PROGRAM_GROUP_NAME="bwamem" \
         UNMAPPED_READ_STRATEGY=COPY_TO_TAG \
         ALIGNER_PROPER_PAIR_FLAGS=true \
         UNMAP_CONTAMINANT_READS=true \
         ADD_PG_TAG_TO_READS=false"""