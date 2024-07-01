process FLAIR_CONCATENATE {
    input:
        tuple val(meta), path(bed)

    output:
        tuple val(meta), path("flair_concatenate.bed"), emit: bed

    container 'docker://quay.io/biocontainers/flair:1.5--hdfd78af_4'

    script:
    """
    cat ${bed} >> flair_concatenate.bed
    """

}