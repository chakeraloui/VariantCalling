rule    
 input:
    "calls/all.vcf"
 output:
    "plots/quals.svg"
 script:
    "scripts/plot-quals.py"
