FROM mambaorg/micromamba
MAINTAINER Colin Davenport github: colindaven

RUN \
   micromamba install -y -n base -c defaults -c bioconda -c conda-forge \
      pandas=1.2.5 \
      python=3.9 \
   && micromamba clean -a -y
