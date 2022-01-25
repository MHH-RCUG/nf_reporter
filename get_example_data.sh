#/bin/bash
# copy example data (added to .gitignore)

eg_dir="/ngsssd1/rcug/wochenende_test/CF_small/"

mkdir reporting 
cp -R $eg_dir/haybaler/ reporting/haybaler/

mkdir raspir
cp -R $eg_dir/raspir/*raspir_final_stats.csv raspir/

#TODO!
#mkdir krakenuniq
#cp -R $eg_dir/raspir/*report.txt krakenuniq/

#mkdir metaphlan
#cp -R $eg_dir/metaphlan/*report.txt metaphlan/