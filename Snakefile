


##### Set up wildcards #####
configfile: "./config/config.yaml"
# Define samples from fastq dir and families/cohorts from pedigree dir using wildcards

FAMILIES, = glob_wildcards("../pedigrees/{family}_pedigree.ped")
SAMPLES, = glob_wildcards("../test/{sample}_R1.fastq.gz") # to adapt


##### Setup helper functions #####
import csv
import glob

def get_input_fastq(command):
    """Return a string which defines the input fastq files for the bwa_mem and pbrun_germline rules.
    This changes based on the user configurable options for trimming
    """
    
    input_files = ""

    if config['TRIM'] == "No" or config['TRIM'] == "no":
        input_files = ["../test/{sample}_R1.fastq.gz", "../test/{sample}_R2.fastq.gz"] # to adapt
    if config['TRIM'] == "Yes" or config['TRIM'] == "yes":
        input_files = ["aligned_reads/{sample}_1_val_1.fq.gz", "aligned_reads/{sample}_2_val_2.fq.gz"]

    return input_files







def get_output_vcf(config):
    """Return a string which defines the output vcf files for the pbrun_germline rule. This changes based on the
    user configurable options for running single samples or cohorts of samples
    """
    
    vcf = ""

    if config['DATA'] == "Single" or config['DATA'] == 'single':
        vcf = "aligned_reads/{sample}_raw_snps_indels.vcf"
    if config['DATA'] == "Cohort" or config['DATA'] == 'cohort':
        vcf = "aligned_reads/{sample}_raw_snps_indels_tmp.g.vcf"

    return vcf

def get_params(command):
    """Return a string which defines some parameters for the pbrun_germline rule. This changes based on the
    user configurable options for running single samples or cohorts of samples
    """
    
    params = ""

    if config['DATA'] == "Single" or config['DATA'] == 'single':
        params = ""
    if config['DATA'] == "Cohort" or config['DATA'] == 'cohort':
        params = "--gvcf"

    return params

def get_gatk_combinegvcf_command(family):
    """Return a string, a portion of the gatk CombineGVCF command which defines individuals which should be combined. This
    command is used by the gatk_CombineGVCFs rule. For a particular family, we construct the gatk command by adding
    -V <individual vcf file> for each individual (defined by individual id column in the pedigree file)
    """
    filename = "../pedigrees/" + str(family) + "_pedigree.ped"
    
    command = ""
    with open(filename, newline = '') as pedigree:

        pedigree_reader = csv.DictReader(pedigree, fieldnames = ('family', 'individual_id', 'paternal_id', 'maternal_id', 'sex', 'phenotype'), delimiter='\t')
        for individual in pedigree_reader:
            command += "-V aligned_reads/" + individual['individual_id'] + "_raw_snps_indels_tmp.g.vcf"

    return command
   
 

def get_recal_resources_command(resource):
    """Return a string, a portion of the gatk BaseRecalibrator command (used in the gatk_BaseRecalibrator and the
    parabricks_germline rules) which dynamically includes each of the recalibration resources defined by the user
    in the configuration file. For each recalibration resource (element in the list), we construct the command by
    adding either --knownSites (for parabricks) or --known-sites (for gatk4) <recalibration resource file>
    """
    
    command = ""
    
    for resource in config['RECALIBRATION']['RESOURCES']:
        command += "--known-sites " + resource + " "
        
    return command

def get_wes_intervals_command(resource):
    """Return a string, a portion of the gatk command's (used in several gatk rules) which builds a flag
    formatted for gatk based on the configuration file. We construct the command by adding either --interval-file
    (for parabricks) or --L (for gatk4) <exome capture file>. If the user provides nothing for these configurable
    options, an empty string is returned
    """
    
    command = ""
    
    if config['WES']['INTERVALS'] == "":
        command = ""
    
    command = "--L " + config['WES']['PADDING'] + " "
    

    return command

def get_wes_padding_command(resource):
    """Return a string, a portion of the gatk command's (used in several gatk rules) which builds a flag
    formatted for gatk based on the configuration file. We construct the command by adding either --interval
    (for parabricks) or --ip (for gatk4) <exome capture file>. If the user provides nothing for these configurable
    options, an empty string is returned
    """
    
    command = ""
    if config['WES']['PADDING'] == "":
        command = ""
    
    command = "--ip " + config['WES']['PADDING'] + " "
    

    return command

#### Set up report #####

report: "report/workflow.rst"

##### Target rules #####

if config['DATA'] == "Single" or config['DATA'] == 'single':
    rule all:
        input:
            "./aligned_reads/multiqc_report.html",
            expand("./aligned_reads/{sample}_recalibrated.bam", sample = SAMPLES),
            expand("./aligned_reads/{sample}_raw_snps_indels.vcf", sample = SAMPLES),
            

if config['DATA'] == "Cohort" or config['DATA'] == 'cohort':
    rule all:
        input:
            "./aligned_reads/multiqc_report.html",
            expand("./aligned_reads/{sample}_recalibrated.bam", sample = SAMPLES),
            expand("./aligned_reads/{family}_raw_snps_indels.vcf", family = FAMILIES)

##### Load rules #####
#localrules: multiqc


include: "rules/fastqc.smk"

if config['TRIM'] == "No" or config['TRIM'] == "no":
    include: "rules/multiqc.smk"

if config['TRIM'] == "Yes" or config['TRIM'] == "yes":
    include: "rules/trim_galore_pe.smk"
    include: "rules/multiqc_trim.smk"

if config['GPU_ACCELERATED'] == "No" or config['GPU_ACCELERATED'] == "no":
    include: "rules/bwa_mem.smk"
    include: "rules/gatk_MarkDuplicates.smk"
    include: "rules/gatk_BaseRecalibrator.smk"
    include: "rules/gatk_ApplyBQSR.smk"

if (config['GPU_ACCELERATED'] == "No" or config['GPU_ACCELERATED'] == "no") and (config['DATA'] == "Single" or config['DATA'] == 'single'):
    include: "rules/gatk_HaplotypeCaller_single.smk"

if (config['GPU_ACCELERATED'] == "No" or config['GPU_ACCELERATED'] == "no") and (config['DATA'] == "Cohort" or config['DATA'] == 'cohort'):
    include: "rules/gatk_HaplotypeCaller_cohort.smk"
    include: "rules/gatk_CombineGVCFs.smk"
    include: "rules/gatk_GenotypeGVCFs.smk"
