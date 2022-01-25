// allows you to define processes to be used for modular libraries
nextflow.enable.dsl = 2

workflow {
    params.output_dir = "output"
    ids = Channel.fromPath('raspir/*.csv')
    chunksize = Channel.value(1000)
    splits = Channel.new
    results = Channel.new
    
    split_ids(ids, chunksize)
    cut_first_column(chunksize)
    
}




//customer_ids = Channel.from(1, 2, 3, 4)
process split_ids {

    text = """
    Just testing
    bla
    """
    println text

    input:
    path(ids)
    val(chunksize)

    x = new java.util.Date()
    println x
 
    output:
    file('batch-*') of splits
     
    shell:
    """
    split -l !{chunksize} !{ids} batch-

    """
}


//horse_channel.view()

process cut_first_column {

    text = """
    Cut first column
    """
    println text


    x = new java.util.Date()
    println x

    input:
    file x from splits
    val(chunksize)

    output:
    stdout results
    

    shell:
    """
    cut -f 1 -d"\t" $x   

    """
}

//results.view { it.trim() } 

// watchPath - script will trigger, but will never finish
//Channel
//   .watchPath( 'raspir/*.csv' )
//   .subscribe { println "CSV file: $it" }

process collect_files {
    publishDir "${params.output_dir}/collect_files", mode: 'copy', overwrite: true

    input:
    file(files:"*") from sample_files.collect()

    output:
    file(files)

    script:
    """
    """

}