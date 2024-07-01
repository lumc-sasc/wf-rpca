process FLAIR_CORRECT {
    input:
        tuple val(meta), path(bed)
        tuple val(meta2), path(annotation)
        tuple val(meta3), path(referenceFasta)

    output:
        tuple val(meta), path("*.bed"), emit: bed


    container 'docker://quay.io/biocontainers/flair:1.5--hdfd78af_4'

    script:
        args = task.ext.args 
        """
        flair.py correct \\
            --genome ${referenceFasta} \\
            --query ${bed} \\
            --gtf ${annotation} \\
            --nvrna \\
            --threads ${task.cpus} \\
            ${args}
        
        cat flair_all_corrected.bed > ${meta.id}_flair_all_corrected.bed
        cat flair_all_inconsistent.bed > ${meta.id}_flair_all_inconsistent.bed
        rm flair_all_corrected.bed
        rm flair_all_inconsistent.bed
        """
}