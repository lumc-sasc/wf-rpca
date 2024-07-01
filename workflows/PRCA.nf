//BEGIN INCLUDE STATEMENTS --------------------------------------------------------------------------------------------------------------

//This part includes the custom code that converts the input samplesheet to a nested list, grouped by samples and readpairs.
include {FILE_CHECK as File_Check}                  from "../lib/main.nf"

//Include modules
include {NANOPLOT as NanoPlot}                      from "../modules/nf-core/nanoplot/main.nf"
include {MINIMAP2_ALIGN as Minimap2_Align}          from "../modules/nf-core/minimap2/align/main.nf"
include {SAMTOOLS_INDEX as Samtools_Index}          from "../modules/nf-core/samtools/index/main.nf"
include {SAMTOOLS_VIEW as Samtools_View}            from "../modules/nf-core/samtools/view/main.nf"
include {SAMTOOLS_STATS as Samtools_Stats}          from "../modules/nf-core/samtools/stats/main.nf"
include {SUBREAD_FEATURECOUNTS as SubRead_FeatureCounts} from "../modules/nf-core/subread/featurecounts/main.nf"
include {ALIGN_STATS as Align_Stats}                from "../modules/local/align_stats/main.nf"
include {FLAIR_BAMTOBED as Flair_BamToBed}    from "../modules/local/flair/bamtobed/main.nf"
include {FLAIR_CORRECT as Flair_Correct}            from "../modules/local/flair/correct/main.nf"
include {FLAIR_CONCATENATE as Flair_Concatenate}    from "../modules/local/flair/concatenate/main.nf"
include {FLAIR_COLLAPSE as Flair_Collapse}          from "../modules/local/flair/collapse/main.nf"

include {OXFORD_FILTER as Oxford_Filter}            from "../modules/local/oxford/filter/main.nf"
include {STRINGTIE_STRINGTIE as Oxford_run_stringtie} from "../modules/nf-core/stringtie/stringtie/main.nf"
include {STRINGTIE_MERGE as Oxford_merge_stringtie} from "../modules/nf-core/stringtie/merge/main.nf"
include {STRINGTIE_STRINGTIE as Oxford_abundance} from "../modules/nf-core/stringtie/stringtie/main.nf"
include {SET_CONFIG as Oxford_config}                from "../modules/local/set_config/main.nf" 

include {GET_SJS_FROM_GTF as Get_Sjs}               from "../modules/local/talon/get_sjs/main.nf"
include {TRANSCRIPTCLEAN as Transcriptclean}        from "../modules/local/talon/transcriptclean/main.nf"
include {TALONLABELREADs as talon_label_reads}      from "../modules/local/talon/talon_label_reads/main.nf" 



workflow PRCA {
    //Add inputfiles
    referenceFasta               = [[id: "Genome"], file(params.genomes[ params.genome ][ 'fasta' ], checkIfExists: true)]
    referenceGtfFile             = file(params.genomes[ params.genome ][ 'referenceGTF' ]).exists() ? [[id: "Genome"], file(params.genomes[ params.genome ][ 'referenceGTF' ])] : [[id: "Genome"], []]


    //Definition of Samplesheet. It will run a custom function that converts samplesheet file to a nested list that is grouped by samples and readpairs.
    fastq_grouped_list = File_Check()

    //Run nanoplot
    NanoPlot(fastq_grouped_list)

    //Run Minimap2

    fastq_grouped_list.map{return [[id: it[0].sample],it[1]]}.groupTuple().map{return [it[0],it[1].flatten()]}.set{Minimap_input}
    Minimap2_Align(Minimap_input, referenceFasta, true, false, false)

    //Create Index
    Samtools_Index(Minimap2_Align.out.bam)

    //Join channels for bam and bai
    BamFiles = Minimap2_Align.out.bam.join(Samtools_Index.out.bai)

    //Execute samtools view to create SAM file.
    Samtools_View(BamFiles, referenceFasta, [])

    //Execute samtools stats
    Samtools_Stats(BamFiles, referenceFasta)

    //Execute align stats
    Samtools_Stats.out.stats.map{ return [[id:"Combined"], it[1]]}.groupTuple().set{align_stats_input}
    align_stats_python_script = file("./modules/local/align_stats/align_stats.py")
    Align_Stats(align_stats_input, align_stats_python_script)

    //Execute Subread_FeatureCounts
    SubRead_FeatureCounts(BamFiles.map{ return [it[0], it[1]]}.combine(Channel.value(referenceGtfFile[1])))

    //Flair steps
    bamtobed_python_script = file("./modules/local/flair/bamtobed/bamtoBed12.py")
    Flair_BamToBed(BamFiles, bamtobed_python_script)
    
    Flair_Correct(Flair_BamToBed.out.bed, referenceGtfFile, referenceFasta).collect()

    Flair_Correct.out.bed.map{ return [[id:"Combined"], it[1]]}.groupTuple().map{return [[id: "Combined"], it[1].flatten()]}.set{Flair_Correct_out}

    Flair_Concatenate(Flair_Correct_out).collect()

    Flair_Collapse(fastq_grouped_list,Flair_Concatenate.out.bed, referenceGtfFile, referenceFasta)

    //Oxford
    Oxford_Filter(Minimap2_Align.out.bam, referenceFasta, file("./modules/local/oxford/filter/filter.py"))

    Oxford_run_stringtie(Oxford_Filter.out.bam, referenceGtfFile[1])

    Oxford_run_stringtie.out.transcript_gtf.map{return [[id: "Combine"],it[1]]}.groupTuple().map{return it[1]}.set{Oxford_run_out}

    Oxford_merge_stringtie(Oxford_run_out, referenceGtfFile[1])
    
    Oxford_abundance(Oxford_Filter.out.bam, Oxford_merge_stringtie.out.gtf)

    Oxford_config(Oxford_abundance.out.transcript_gtf, fastq_grouped_list.map{it[0].id}, file("./modules/local/set_config/set_config.py"))



    //Talon
    Get_Sjs(referenceGtfFile, referenceFasta)
    Transcriptclean(Samtools_View.out.sam, referenceFasta, Get_Sjs.out.spliceJns)






    //NanoPlot output for MultiQC
    NanoPlot.out.html.map { instance ->
        identification = "report"
            reports = instance.subList(1, instance.size())
            return [[id:identification], reports]}.groupTuple().set{NanoPlot_reports}

    //Samtools stats for MultiQC
    Samtools_Stats.out.stats.map{ instance ->
        identification = "report"
            reports = instance.subList(1, instance.size())
            return [[id:identification], reports]}.groupTuple().set{Samtools_Stats_reports}
    
    

    

}