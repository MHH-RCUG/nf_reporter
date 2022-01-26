// allows you to define processes to be used for modular libraries
nextflow.enable.dsl = 2

workflow {
    params.output_dir = "output"
    csvs = Channel.fromPath('raspir/*.csv')
    chunksize = Channel.value(1000)

    split_csvs(csvs, chunksize)
    cut_first_column(csvs, chunksize)
    cut_first_column.out.somecrap.view()
    
    pandas_unique(cut_first_column.out.somecrap)
    
}




//customer_csvs = Channel.from(1, 2, 3, 4)
process split_csvs {

    text = """
    Just testing split csvs
    """
    println text

    input:
    path(csvs)
    val(chunksize)

    x = new java.util.Date()
    println x
 
    output:
    file('batch-*')
     
    shell:
    """
    split -l !{chunksize} !{csvs} batch-

    """
}



process cut_first_column {

    text = """
    Cut first column
    """
    println text


    x = new java.util.Date()
    println x

    input:
    file x
    val(chunksize)

    output:
    //path "$x.txt"
    // Named stdout pipe
    stdout emit: somecrap

    shell:
    """
    cut -f 1 -d"," $x | head -n 5 

    """
}

process pandas_unique {
    conda '/mnt/ngsnfs/tools/miniconda3/envs/haybaler'

    input:
    stdin

    output:
    stdout emit: pandascrap

    shell:
    """
    python haybaler.py

    """
}



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
