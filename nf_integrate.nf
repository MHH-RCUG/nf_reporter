// Integrate multiple information sources from Wochenende_postprocess.sh
// Eg. add growth rate and raspir results to Haybaler output.
// Colin Davenport March - April 2022
// Lisa Hollstein March - August 2022
// Janno Peilert August 2022

// use modern nextflow
nextflow.enable.dsl = 2

//choose which directories to use
    use_kraken = false
    use_raspir = false
    use_growth_rate = true


workflow {
    params.output_dir = "output"

    // File inputs
    reporting_csvs = Channel.fromPath('reporting/haybaler/*.csv', checkIfExists: true)
    chunksize = Channel.value(1000)

    // run processes
    
    // test filenames read by nextflow from raspir and reporting have the same stem -looks good
    //test_filenames_same(raspir_csvs, reporting_csvs, growth_rate_csvs, kraken)
    //test_filenames_same.out.filessame.view()

    // run integration step python script
    run_integration(reporting_csvs)
    run_integration.out.pandas_out.view()

    sleep(10)


    // Rerun a modified Haybaler script. Env variable $HAYBALER_DIR must be set)
    run_reporter_haybaler(run_integration.out.nf_reporting_csv.collect())
    run_reporter_haybaler.out.haybaler_out.view()

    // Run Haybaler heatmap scripts using Haybaler output
    run_heatmap_scripts(run_reporter_haybaler.out.haybaler_csvs.flatten())
    run_heatmap_scripts.out.heatmap_out.view()

    // Run Haybaler heattree scripts using Haybaler output
    run_heattree_scripts(run_reporter_haybaler.out.haybaler_heattree_csvs)
    run_heattree_scripts.out.heattree_out.view()

    /*
    TODO add kraken instead of raspir
    run_heattree_scripts(run_reporter_haybaler.out.haybaler_heattree_csvs)
    run_heattree_scripts.out.heattree_out.view()
    */

}







process run_integration {
    //executor = "slurm"
    
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
    file reporting_csv

    output:
    path '*.nf_reporting.csv', emit: nf_reporting_csv
    stdout emit: pandas_out
    
    //println "Filename" $raspir_csv.getBaseName()

    // Use current dir as default
    $projectDir = "."

    script:

    //name = reporting_csv

    //String[] array
    name = reporting_csv.getSimpleName()
    println name





    //variables for filenames
    kraken_file_name = ""
    raspir_file_name = ""
    growth_rate_file_name = ""

    //variables for next script
    param_re=" -re $reporting_csv "
    param_ra=""
    param_g=""
    param_k=""

    if (use_kraken=true) {
        kraken_file_name = name + ".fastq.report.txt"}
        param_k="-k $kraken_file_name "
    if (use_raspir=true) {
        raspir_file_name = name + ".ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv"}
        param_ra=" -ra $raspir_file_name "
    if (use_growth_rate=true) {
        growth_rate_file_name = name + ".ndp.trm.s.mm.dup.mq30.calmd_subsamples_results.csv"}
        param_g=" -g $growth_rate_file_name "



    """
    if $use_kraken
    then
        ln -s ${launchDir}/kraken/$name*report.txt .
        #echo $kraken_file_name


    fi

    if $use_raspir
    then
        ln -s ${launchDir}/raspir/$name*final_stats.csv .

        #echo $raspir_file_name
        #head -n 2 ${launchDir}/raspir/$raspir_file_name >> output-file.txt
        #echo "Used raspir"
    fi

    if $use_growth_rate
    then
        ln -s ${launchDir}/growth_rate/fit_results/output/$name*.csv .
        #echo $growth_rate_file_name
        #head -n 2 ${launchDir}/growth_rate/fit_results/output/$growth_rate_file_name >> output-file.txt
        #echo "Used growth_rate"
    fi


    python3 $projectDir/join_csvs.py $param_ra $param_re $param_g $param_k
    """



}





process run_reporter_haybaler {
    //executor = "slurm"

    publishDir "${params.output_dir}/", mode: 'copy', overwrite: true

    conda params.conda_haybaler


    input:
    file nf_reporting_csvs

    output:
    //TODO: Add kraken output
    path 'raspir_haybaler_output/*haybaler*.csv', emit: haybaler_csvs
    path 'raspir_haybaler_output/*haybaler.csv', emit: haybaler_heattree_csvs
    path 'raspir_haybaler_output'
    stdout emit: haybaler_out

    // Use current dir as default
    $projectDir = "."

    script:
    """
    sleep 10
    bash $projectDir/run_reporter_haybaler.sh $projectDir $use_kraken
    """



}





process run_heatmap_scripts {
    executor = "local"
    publishDir "${params.output_dir}/raspir_haybaler_output/", mode: 'copy', overwrite: true
    // create heatmaps

    input:
    file heatmap_file

    output:
    path 'top*taxa/*'
    path '*filt.heatmap.csv'
    stdout emit: heatmap_out


    // Use current dir as default
    $projectDir = "."

    """
    cp $projectDir/runbatch_heatmaps.sh $projectDir/create_heatmap.R .
    bash runbatch_heatmaps.sh
    """




}





process run_heattree_scripts {
    executor = "local"
    publishDir "${params.output_dir}/raspir_haybaler_output/", mode: 'copy', overwrite: true
    // create heattrees

    conda params.conda_haybaler

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
    Recd  reporting and raspir files. Limit reporting rows to those rows contained in raspir output,  using pandas. Filename test.
    """
    println text


    input:
    file raspir_csv
    file reporting_csv
    file growth_rate_csv
    file kraken

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

