process OXFORD_CALCULATE_ABUNDANCE {
    input:
        tuple val(meta), path(bam)
        tuple val(meta2), path(referenceGtfFile)
        tuple val(meta3), path(referenceFasta) 

    
    script:
        """
        declare -i calc=0;
        for line in {input.stats}
        do
           numb=$(awk 'NR==33 {{print $4}}' < ${{line}});
           calc+=$((${{numb}}));
        done;
        words=$(echo {input.stats} | wc -w);
        avg_len=$((${{calc}} / ${{words}}));

        prepDE.py \
            -i {input.config_file} \\
            -l ${{avg_len}} \
            -g {output.genes} \
            -t {output.transcripts}
        """
}