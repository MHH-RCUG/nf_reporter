// use modern nextflow (does not allow into or create keywords)
nextflow.enable.dsl = 2

workflow {
    params.output_dir = "output"

    // File inputs
    raspir_csvs = Channel.fromPath('raspir/*.csv')
    reporting_csvs = Channel.fromPath('reporting/haybaler/*.csv')
    chunksize = Channel.value(1000)

    // run processes
    cut_first_column(raspir_csvs, chunksize)
    cut_first_column.out.somecrap.view()

    // test filenames read by nextflow from raspir and reporting have the same stem -looks good
    test_filenames_same(raspir_csvs, reporting_csvs)
    test_filenames_same.out.filessame.view()

    //pandas_unique(cut_first_column.out.somecrap)
    pandas_unique(raspir_csvs, reporting_csvs)
    pandas_unique.out.pandascrap.view()    


    //collect_files()
}







process cut_first_column {

    text = """
    Cut first column and print the first five lines 
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
    //stdout emit: somecrap

    shell:
    """
    cut -f 1 -d"," $x | head -n 5 

    """
}

process pandas_unique {
    conda '/mnt/ngsnfs/tools/miniconda3/envs/haybaler'

    text = """
    Run as: nextflow run main.nf
    Requires: python pandas library (python -m pip install --user pandas)
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
    echo "Test - this works, pandas is found"
    echo "Lisa can add script  with input argument 1 being raspir_csv and arg 2 being reporting_csv"
    #python $projectDir/haybaler.py
    # TODO Lisa to add script here
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
    stdout emit: filessame

    script:
    // check file names match. A bash script

    //            raspir/1_sm_R1.ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv
    //reporting/haybaler/1_sm_R1.ndp.trm.s.mm.dup.mq30.bam.txt.rep.us.csv
    // vars do not get substituted
    //println "Filename $raspir_csv"
    //println "Filename $reporting_csv"
    
    """
    echo "Filename $raspir_csv"
    echo "Filename $reporting_csv"
    

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
    /usr/bin/env python
    print "python not bash"

    """

}

