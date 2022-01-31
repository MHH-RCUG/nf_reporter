// use modern nextflow (does not allow into or create keywords)
nextflow.enable.dsl = 2

workflow {
    params.output_dir = "output"

    // File inputs
    raspir_csvs = Channel.fromPath('raspir/*.csv')
    reporting_csvs = Channel.fromPath('reporting/haybaler/*.csv')
    chunksize = Channel.value(1000)

    // run processes
    split_csvs(raspir_csvs, chunksize)
    cut_first_column(raspir_csvs, chunksize)
    cut_first_column.out.somecrap.view()
    
    //pandas_unique(cut_first_column.out.somecrap)
    pandas_unique(raspir_csvs, reporting_csvs)
    pandas_unique.out.pandascrap.view()    

    test_filenames_same(raspir_csvs, reporting_csvs)
    pandas_unique.out.files_same.view()    
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

    text = """
    Read reporting and raspir files. Limit reporting rows to those rows contained in raspir output,  using pandas
    """
    println text


    input:
    file raspir_csv
    file reporting_csv

    output:
    stdout emit: pandascrap
    
    //println "Filename" $raspir_csv.getBaseName()
    //println "Filename" $reporting_csv


    shell:
    """
    echo "test"
    python $projectDir/haybaler.py

    """



}



//////////////////////////////////////////////////////



process test_filenames_same {
    conda '/mnt/ngsnfs/tools/miniconda3/envs/haybaler'

    text = """
    Read reporting and raspir files. Limit reporting rows to those rows contained in raspir output,  using pandas. Filename test.
    """
    println text


    input:
    file raspir_csv
    file reporting_csv

    output:
    stdout emit: files_same

    script:
    // check file names match ?

    //            raspir/1_sm_R1.ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv
    //reporting/haybaler/1_sm_R1.ndp.trm.s.mm.dup.mq30.bam.txt.rep.us.csv
    """
    println "Filename" $raspir_csv
    println "Filename" $reporting_csv
    
    //r = $raspir_csv.toString()
    //p = $reporting_csv.toString()
    //r = $raspir_csv.startsWith()
    //p = $reporting_csv.startsWith()
    //if( $r.substring(0,9) =~ /$p.substring(0,9)/ ) {
    //   println "Filename " $r " matched filename " $p
    //}
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




process split_csvs {

    text = """
    Just testing split csvs
    """
    println text

    input:
    path(raspir_csvs)
    val(chunksize)

    x = new java.util.Date()
    println x
 
    output:
    file('batch-*')
     
    shell:
    """
    split -l !{chunksize} !{raspir_csvs} batch-

    """
}