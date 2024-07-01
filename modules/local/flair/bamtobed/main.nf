process FLAIR_BAMTOBED {
    input:
        tuple val(meta), path(bam), path(bai)
        path(python_script)
    
    output:
        tuple val(meta), path("*.bed12"), emit: bed

    container 'bam2bed12.sif'
    
    script:
    """
    python3 ${python_script.target} --input_bam ${bam} > ${meta.id}.bed12
    """
}