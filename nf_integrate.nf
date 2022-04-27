// Integrate multiple information sources from Wochenende_postprocess.sh
// Eg. add growth rate and raspir results to Haybaler output.
// Colin Davenport, Lisa Hollstein March 2022

// use modern nextflow
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

    // This channel is ineffective, since it works on results from the first steps ... (circular argument). We need another solution
    sleep(10)


    // Rerun a modified Haybaler script. Env variable $HAYBALER_DIR must be set)
    run_reporter_haybaler(run_integration.out.nf_reporting_csv.collect())
    run_reporter_haybaler.out.haybaler_out.view()

    // heatmaps
    run_heatmap_scripts(run_reporter_haybaler.out.haybaler_csvs.flatten())
    //run_heatmap_scripts.out.heatmap_out.view()

    // heattrees
    run_heattree_scripts(run_reporter_haybaler.out.haybaler_heattree_csvs)
    //run_heattree_scripts.out.heattree_out.view()


}







process run_integration {
    
    publishDir "${params.output_dir}/", mode: 'copy', overwrite: true
    conda '/mnt/ngsnfs/tools/miniconda3/envs/haybaler'

    text = """
    Run as: nextflow run nf_integrate.nf
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
    path '*.nf_reporting.csv', emit: nf_reporting_csv
    //file '*.nf_report.csv', emit: nf_reporting_csv
    stdout emit: pandas_out
    
    //println "Filename" $raspir_csv.getBaseName()
    //println "Filename" $reporting_csv

    // Use current dir as default
    $projectDir = "."

    shell:
    """
    python3 $projectDir/join_csvs.py -ra $raspir_csv -re $reporting_csv  -g $growth_rate_csv
    """



}





process run_reporter_haybaler {

    publishDir "${params.output_dir}/", mode: 'copy', overwrite: true
    conda '/mnt/ngsnfs/tools/miniconda3/envs/haybaler'


    input:
    file nf_reporting_csvs

    output:
    path 'raspir_haybaler_output/*haybaler*.csv', emit: haybaler_csvs
    path 'raspir_haybaler_output/*haybaler.csv', emit: haybaler_heattree_csvs
    path 'raspir_haybaler_output'
    stdout emit: haybaler_out

    // Use current dir as default
    $projectDir = "."

    shell:
    """
    sleep 10
    bash $projectDir/run_reporter_haybaler.sh $projectDir
    """



}





process run_heatmap_scripts {
    publishDir "${params.output_dir}/raspir_haybaler_output/", mode: 'copy', overwrite: true
    // create heatmaps

    input:
    file heatmap_file

    output:
    path 'top*taxa/*'
    stdout emit: heatmap_out


    // Use current dir as default
    $projectDir = "."

    """
    cp $projectDir/runbatch_heatmaps.sh $projectDir/create_heatmap.R .
    bash runbatch_heatmaps.sh
    """




}





process run_heattree_scripts {
    publishDir "${params.output_dir}/raspir_haybaler_output/", mode: 'copy', overwrite: true
    // create heattrees

    input:
    file heattree_files

    output:
    path 'heattree_plots'
    path '*.csv'
    stdout emit: heattree_out

    // Use current dir as default
    $projectDir = "."

    """
    cp $projectDir/run_haybaler_tax.sh $projectDir/haybaler_taxonomy.py .
    bash run_haybaler_tax.sh
    cp $projectDir/create_heattrees.R $projectDir/run_heattrees.sh .
    bash run_heattrees.sh
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

