# nf_reporter
Integrate metagenomic reports.

Authors: Colin Davenport, Lisa Hollstein

## Goal - metagenomic data integration: 
- integrate multiple metagenomic reports into one table (preferably: haybaler ?)
- So species found by raspir should be listed as "raspir_positive" or "raspir_negative" in the haybaler table (in a new column)
- later, species found by krakenuniq and metaphlan should be treated simularly (new column in haybaler)
- provide multiple views of this table for different stakeholders



## Run 

`nextflow run main.nf`

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


ideally after raspir (slow) and before haybaler

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
