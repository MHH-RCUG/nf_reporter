# Lisa Hollstein, March-April 2022
# Script to create temporary csv files only with bacteria matching certain criteria
# Output files are needed to start Haybaler for those bacteria
# Input: nf_reporting.csv, criteria to select bacteria

import click
import pandas as pd


@click.command()
@click.option('--input_file', '-f', help='Name of file to be adjusted')
@click.option('--column', '-c', help='Column after which data gets selected')
@click.option('--growth_class', '-g', help='If column=growth_class select which class should be used')
def main(input_file, column, growth_class):
    df = pd.read_csv(input_file)
    if column == "raspir":
        # creating csv containing only raspir positive bacteria
        df = df[df["raspir"] == "raspir_positive"]
        df.drop(columns=["raspir", "growth_class", "growth_rate", "krakenuniq_reads", "species_kraken"],
                inplace=True, errors="ignore")
    elif column == "growth":
        # creating csv containing only bacteria of specific growth classes
        print("Selected growth. This can't be done yet")
    df.to_csv(input_file + ".rasp.csv", sep=",", index=False)


if __name__ == '__main__':
    main()
