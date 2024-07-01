process TRANSCRIPTCLEAN {
    input:
    tuple val(meta), path(sam)
    tuple val(meta2), path(referenceFasta)
    tuple val(meta3), path(spliceJns)

    output:
        tuple val(meta), path("${meta.id}_clean.sam"), emit: clean_sam
    
    container "transcriptclean_v2.0.2_cv1.sif"

    script:
    cpus = task.cpus
    args = task.ext.args
    """
    TranscriptClean \\
    --sam ${sam} \\
    --genome ${referenceFasta} \\
    -t ${cpus} \\
    --spliceJns ${spliceJns} \\
    --outprefix ${meta.id}_clean \\
    ${args}
    """

}
