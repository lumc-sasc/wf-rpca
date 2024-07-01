process ALIGN_STATS {
    input:
        tuple val(meta), path(input)
        path(python_script)

    output:
        tuple val(meta), path("*.png")

    container 'python_libraries.sif'
    
    script:
        """
        python3 ${python_script} ${input} ${meta.id}
        """
}