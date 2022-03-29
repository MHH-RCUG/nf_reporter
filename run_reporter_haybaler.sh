#!/bin/bash
# Lisa Hollstein, March 2022
# Run Haybaler for nf_reporter files using only bacteria matching certain requirements

# Requires Haybaler https://github.com/MHH-RCUG/haybaler
# Requires Haybaler conda environment https://github.com/MHH-RCUG/haybaler#installation-via-conda
# Requires Wochenende https://github.com/MHH-RCUG/Wochenende

projectDir=$1

raspOutDir=raspir_haybaler_output
if [[ ! -d $raspOutDir ]]
then
  echo "INFO: Creating directory:" $raspOutDir
  mkdir $raspOutDir
fi

# Setup config
source $WOCHENENDE_DIR/scripts/parse_yaml.sh
eval $(parse_yaml $WOCHENENDE_DIR/config.yaml)
# Setup conda and directories
. $CONDA_SH_PATH
conda activate $HAYBALER_CONDA_ENV_NAME

cp $HAYBALER_DIR/*.py $raspOutDir
cp $HAYBALER_DIR/haybaler.py .
cp $HAYBALER_DIR/runbatch_heatmaps.sh $raspOutDir
cp $HAYBALER_DIR/create_heatmap.R $raspOutDir
cp $HAYBALER_DIR/run_heattrees.sh $raspOutDir
cp $HAYBALER_DIR/create_heattrees.R $raspOutDir
cp $HAYBALER_DIR/run_haybaler_tax.sh $raspOutDir

# cleanup possible old haybaler runs
count=$(ls -1 $raspOutDir/*haybaler.csv 2>/dev/null | wc -l)
if [[ $count != 0 ]]
then
  rm $raspOutDir/*haybaler.csv
fi
rm -f excluded_taxa.csv
rm -f *rasp.csv


# create input files with only raspir_positive bacteria
for file in *nf_reporting.csv
do
  python3 $projectDir/adjust_files.py -f $file -c "raspir"
done


rasp_input_files=""

# run for all *rasp.csv in directory
count=$(ls -1 *rasp.csv 2>/dev/null | wc -l)
if [[ count != 0 ]]
then
  for csv in *rasp.csv
  do
    rasp_input_files="$rasp_input_files;$csv"
  done
fi


# start Haybaler for all raspir positive bacteria
python3 $projectDir/haybaler.py -i "$rasp_input_files" -p . -op $raspOutDir -o raspir_haybaler.csv


# cleanup
rm *rasp.csv

# Move log file into log directory
mkdir -p $raspOutDir/logs
mv $raspOutDir/excluded_taxa.csv $raspOutDir/logs/
