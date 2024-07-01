process FLAIR_COLLAPSE {
    input:
    tuple val(meta), path(reads)
    tuple val(meta2), path(bed)
    tuple val(meta3), path(referenceGtf)
    tuple val(meta4), path(referenceFasta)

    output:
    tuple val(meta), path("*.fa")
    tuple val(meta), path("*.gtf")

    container 'docker://quay.io/biocontainers/flair:1.5--hdfd78af_4'

    script:
        args = task.ext.args
        """
        flair.py collapse \\
            --genome ${referenceFasta} \\
            --gtf ${referenceGtf} \\
            --reads ${reads} \\
            --query ${bed} \\
            --temp_dir {params.temp_dir} \\
            --generate_map \\
            ${args}

        """
}