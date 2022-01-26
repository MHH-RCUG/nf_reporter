# nf_reporter
Integrate metagenomic reports

Authors: Colin Davenport, Lisa Hollstein

## Goal: 
- integrate multiple metagenomic reports into one table. 
- provide multiple views of this table for different stakeholders



## Run 
nextflow run main.nf

## Install
Setup nextflow as per their website

Perhaps add pandas

```
conda deactivate
python -m pip --user pandas=1.2.5
```




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
        └── haybaler_output
            ├── bacteria_per_human_cell_haybaler.csv
            ├── bacteria_per_human_cell_haybaler.csv.filt.heatmap.csv
            ├── bacteria_per_human_cell_haybaler_short.csv
            ├── bacteria_per_human_cell_haybaler_short.csv.filt.heatmap.csv
            ├── bacteria_per_human_cell_haybaler_taxa.csv
            ├── bacteria_per_human_cell_heattree.csv
```
