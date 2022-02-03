# Script to combine reporting and raspir output
# Lisa Hollstein, Feb 2022


import click
import pandas as pd
import os


def read_csv(input_file):
    file = pd.read_csv(input_file, sep=",")
    return(file)

def compare_files(raspir, df):
    # add value "positive" to raspir column if species was detected by raspir
    df.loc[df["species"].isin(raspir["Species"]), "raspir"] = "positive"
    return(df)

def save_csv(df, reporting):
    save_name = os.path.basename(reporting) + ".nf_reporting.csv"
    df.to_csv(save_name, sep=",")



@click.command()
@click.option('--raspir', '-ra', help='Name of raspir input file')
@click.option('--reporting', '-re', help='Name of reporting input file')

def main(raspir, reporting):
    raspir_df = read_csv(raspir)
    reporting_df = read_csv(reporting)

    # add new column to reporting
    working_df = reporting_df
    working_df["raspir"] = "negative"
    # !!! decide what to do with human reads !!!

    # just raspir positive/negative or more gradation/information from raspir???

    df = compare_files(raspir_df, working_df)

    save_csv(df, reporting)



if __name__ == '__main__':
    main()