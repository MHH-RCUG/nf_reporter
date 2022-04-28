# nf_reporter
Integrate metagenomic reports

Authors: Colin Davenport, Lisa Hollstein

## Goal - metagenomic data integration: 
- integrate multiple metagenomic reports into one table.
- So species found by raspir should be listed as "raspir_positive" or "raspir_negative" in the haybaler table (in a new column)
- later, species found by krakenuniq and metaphlan should be treated simularly (new column in haybaler)
- provide multiple views of this table for different stakeholders


## How does this fit into Wochenende/Haybaler ?
- nf_reporter should be run after Wochenende and Haybaler (i.e. using wochenende_postprocess.sh ) have been completed
- The original Haybaler scripts don't need any more changes
- We just refine the voluminous but unintegrated data output by wochenende_postprocess.sh to help users.


## Run 
Copy all Haybaler files for heattree and heatmap creation into directory

`cp path/to/haybaler/runbatch_heatmaps.sh path/to/haybaler/create_heatmap.R .`

`cp path/to/haybaler/run_haybaler_tax.sh path/to/haybaler/haybaler_taxonomy.py .`

`cp path/to/haybaler/create_heattrees.R path/to/haybaler/run_heattrees.sh .`

Run nextflow script on a server where R is installed

`nextflow run nf_integrate.nf`

## Install

Setup nextflow as per their website

Perhaps add pandas

```
conda deactivate
python -m pip --user pandas=1.2.5
```

## Get example files

`bash get_example_data.sh`




Merging options


ideally after raspir

```

├── raspir
│   ├── 1_sm_R1.ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv
│   ├── 2_sm_R1.ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv
│   ├── 3_sm_R1.ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv
│   ├── 4_sm_R1.ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv
│   └── 5_sm_R1.ndp.trm.s.mm.dup.mq30.raspir_final_stats.csv
├── README.md
└── reporting
    └── haybaler
        ├── 1_sm_R1.ndp.trm.s.mm.dup.mq30.bam.txt.rep.us.csv
        ├── 2_sm_R1.ndp.trm.s.mm.dup.mq30.bam.txt.rep.us.csv
        ├── 3_sm_R1.ndp.trm.s.mm.dup.mq30.bam.txt.rep.us.csv
        ├── 4_sm_R1.ndp.trm.s.mm.dup.mq30.bam.txt.rep.us.csv
        ├── 5_sm_R1.ndp.trm.s.mm.dup.mq30.bam.txt.rep.us.csv

.
└── fit_results
    └── output
        ├── 1_sm_R1.ndp.trm.s.mm.dup.mq30.calmd_subsamples_results.csv
        ├── 2_sm_R1.ndp.trm.s.mm.dup.mq30.calmd_subsamples_results.csv
        ├── 3_sm_R1.ndp.trm.s.mm.dup.mq30.calmd_subsamples_results.csv
        ├── 4_sm_R1.ndp.trm.s.mm.dup.mq30.calmd_subsamples_results.csv
        └── 5_sm_R1.ndp.trm.s.mm.dup.mq30.calmd_subsamples_results.csv


```
