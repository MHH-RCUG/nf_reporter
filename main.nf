// use modern nextflow (does not allow into or create keywords)
nextflow.enable.dsl = 2

workflow {
    params.output_dir = "output"

    // File inputs
    raspir_csvs = Channel.fromPath('raspir/*.csv')
    reporting_csvs = Channel.fromPath('reporting/haybaler/*.csv')
    growth_rate_csvs = Channel.fromPath('growth_rate/fit_results/output/*.csv')
    chunksize = Channel.value(1000)

    // run processes
    cut_first_column(raspir_csvs, chunksize)
    cut_first_column.out.somecrap.view()

    // test filenames read by nextflow from raspir and reporting have the same stem -looks good
    test_filenames_same(raspir_csvs, reporting_csvs,growth_rate_csvs)
    test_filenames_same.out.filessame.view()

    pandas_unique(raspir_csvs, reporting_csvs,growth_rate_csvs)
    pandas_unique.out.pandascrap.view()    


    //collect_files()
}







process cut_first_column {

    input:
    file x
    val(chunksize)

    output:
    //path "$x.txt"
    // Named stdout pipe
    stdout emit: somecrap

    shell:
    """
    #cut -f 1 -d"," $x | head -n 5
    cut -f 1 -d"," $x | head -n 5 >/dev/null

    """
}

process pandas_unique {
    conda '/mnt/ngsnfs/tools/miniconda3/envs/haybaler'

    text = """
    Run as: nextflow run main.nf
    Requires: python pandas library - see README.md
    Read reporting and raspir files. Limit reporting rows to those rows contained in raspir output,  using pandas
    Add growth_rate data, then data from other tools.
    """
    println text


    input:
    file raspir_csv
    file reporting_csv
    file growth_rate_csv

    output:
    stdout emit: pandascrap
    
    //println "Filename" $raspir_csv.getBaseName()
    //println "Filename" $reporting_csv


    shell:
    """
    python3 $projectDir/join_csvs.py -ra $raspir_csv -re $reporting_csv -d $projectDir -g $growth_rate_csv
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
    file growth_rate_csv

    output:
    stdout emit: filessame

    script:
    
    """
    echo "Filename $raspir_csv"
    echo "Filename $reporting_csv"
    echo "Filename $growth_rate_csv"
    

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

