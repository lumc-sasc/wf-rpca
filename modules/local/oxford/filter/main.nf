process OXFORD_FILTER {
    input:
    tuple val(meta), path(bam)
    tuple val(meta2), path(fasta)
    path(script)

    output:
    tuple val(meta), path("${meta.id}_filtered.bam"), emit: bam

    container = 'oxford.sif'

    script:
    oxford_mapping_quality = task.ext.mapping_quality

    """
    python3 filter.py ${fasta} ${task.ext.poly_context} ${task.ext.max_poly_run}
    samtools view -q ${oxford_mapping_quality} -F 2304 -b ${bam} \\
        | seqkit bam -j ${task.cpus} -x -T '{Yaml: "output.yaml"}' \\
        | samtools sort -@ ${task.cpus} -o ${meta.id}_filtered.bam 
        samtools index ${meta.id}_filtered.bam
    """

}