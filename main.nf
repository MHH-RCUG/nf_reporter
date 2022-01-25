// allows you to define processes to be used for modular libraries
nextflow.enable.dsl = 2

workflow {
    ids = Channel.fromPath('raspir/*.csv')
    chunksize = Channel.value(1000)
    split_ids(ids, chunksize)
}
process split_ids {
    input:
    path(ids)
    val(chunksize)
 
    output:
    file('batch-*')
 
    shell:
    """
    split -l !{chunksize} !{ids} batch-
    """
}
