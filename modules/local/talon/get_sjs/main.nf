process GET_SJS_FROM_GTF {
    input:
    tuple val(meta), path(referenceGtf)
    tuple val(meta2), path(referenceFasta)

    output:
    tuple val(meta), path("spliceJns.txt"), emit: spliceJns

    container "transcriptclean_v2.0.2_cv1.sif"

    script:
    """
    get_SJs_from_gtf \\
        --f ${referenceGtf} \\
        --g ${referenceFasta} \\
        --o spliceJns.txt
    """
}