process TALONLABELREADs {
    input:
    tuple val(meta), path(sam)
    tuple val(meta2), path(fasta)

    output val(meta), path("${sample}_labeled.sam")



    container "docker://biocontainers/talon:v5.0_cv1"

    script:
    cpus  = task.ext.cpus
    """
    talon_label_reads \\
            --f ${sam} \\
            --g ${fasta} \\
            --t {threads} \\
            --ar 20 \\
            --deleteTmp \\
            --o ${sample}_labeled.sam
    """
}