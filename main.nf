// allows you to define processes to be used for modular libraries
nextflow.enable.dsl = 2

workflow {
    ids = Channel.fromPath('raspir/*.csv')
    chunksize = Channel.value(1000)
    split_ids(ids, chunksize)
    //horse_channel = Channel
    cut_first_column = Channel
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
    file('batch-*')
    //file horse into horse_channel
 
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
 
    Channel
    .of(1..23, 'X', 'Y')
    .view()

    output:
    file('batch-*')

    input:
    path(ids)
    val(chunksize)

    
    

    shell:
    """
    split -l !{chunksize} !{ids} batch-

    """
}


// watchPath - script will trigger, but will never finish
//Channel
//   .watchPath( 'raspir/*.csv' )
//   .subscribe { println "CSV file: $it" }
