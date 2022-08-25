#/bin/bash
# copy example data (added to .gitignore)

eg_dir="/ngsssd1/rcug/wochenende_test/CF_small"
kraken_eg_dir="/ngsssd1/rcug/lisa/test_data"

mkdir -p reporting reporting/haybaler reporting/haybaler/haybaler_output/
cp -R $eg_dir/reporting/haybaler/*.csv reporting/haybaler/
cp -R $eg_dir/reporting/haybaler/haybaler_output/*.csv reporting/haybaler/haybaler_output/

mkdir -p raspir
cp -R $eg_dir/raspir/*raspir_final_stats.csv raspir/

mkdir -p growth_rate
mkdir -p growth_rate/fit_results
mkdir -p growth_rate/fit_results/output
cp $eg_dir/growth_rate/fit_results/output/*.csv  growth_rate/fit_results/output

mkdir -p kraken
cp $kraken_eg_dir/kraken/*species.filt.txt kraken

#TODO!
#mkdir -p krakenuniq
#cp -R $eg_dir/raspir/*report.txt krakenuniq/

#mkdir -p metaphlan
#cp -R $eg_dir/metaphlan/*report.txt metaphlan/
