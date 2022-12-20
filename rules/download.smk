rule download:
    output:
        "path/to/file.txt"
    shell:
        "wget --continue {output}.part && mv {output}.part {output}"
