process SET_CONFIG {
    input:
    tuple val(meta), path(gtf)
    tuple val(meta2), path(reads)
    path(file)

    output:
    tuple val(meta), path("*.tab")

    script:

    """
    python3 set_config.py ${gtf} ${reads}
    """
}