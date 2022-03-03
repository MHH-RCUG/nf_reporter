// use modern nextflow (does not allow into or create keywords)
nextflow.enable.dsl = 2

workflow {
    params.output_dir = "output"

    // File inputs
    raspir_csvs = Channel.fromPath('raspir/*final_stats.csv', checkIfExists: true)
    reporting_csvs = Channel.fromPath('reporting/haybaler/*.csv', checkIfExists: true)
    growth_rate_csvs = Channel.fromPath('growth_rate/fit_results/output/*.csv', checkIfExists: true)
    chunksize = Channel.value(1000)

    // run processes
    
    // test filenames read by nextflow from raspir and reporting have the same stem -looks good
    test_filenames_same(raspir_csvs, reporting_csvs,growth_rate_csvs)
    test_filenames_same.out.filessame.view()

    // run integration step python script
    run_integration(raspir_csvs, reporting_csvs,growth_rate_csvs)
    run_integration.out.pandas_out.view()    


    //collect_files()
}







process run_integration {
    
    publishDir "${params.output_dir}/", mode: 'copy', overwrite: true
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
    stdout emit: pandas_out
    
    //println "Filename" $raspir_csv.getBaseName()
    //println "Filename" $reporting_csv

    // Use current dir as default
    $projectDir = "."

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

