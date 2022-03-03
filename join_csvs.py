# Script to combine reporting, growth_rate and raspir output
# Lisa Hollstein, Feb 2022


import click
import pandas as pd
import os
import warnings


def read_csv(input_file):
    file = pd.read_csv(input_file, sep=",")
    return file


def add_raspir(raspir, df):
    df["raspir"] = "raspir_neg"  # add raspir column to reporting
    # assert "positive" to raspir column if species was detected by raspir
    df.loc[df["species"].isin(raspir["Species"]), "raspir"] = "raspir_positive"
    return df


def add_growth(growth, df):
    # add growth class and growth rate to dataframe
    df["growth_class"] = ""
    df["growth_rate"] = ""
    for species in df["species"]:
        # get name in growth for species in df (name in growth contains species name)
        growth_species = [name for name in growth["Name"] if species in name]
        if len(growth_species) > 0:  # check if growth rate was evaluated for species
            growth_species = growth_species[0]
            # add growth class
            df.loc[df["species"] == species, "growth_class"] = growth.loc[growth["Name"] == growth_species,
                                                                          "Growth_class"].values[0]
            # add growth rate
            df.loc[df["species"] == species, "growth_rate"] = growth.loc[growth["Name"] == growth_species,
                                                                         "Growth_Rate"].values[0]
    return df


def save_csv(df, reporting, output_dir):
    save_name = os.path.basename(reporting) + ".nf_reporting.csv"  # set save name
    df.to_csv(output_dir + "/" + save_name, sep=",")  # save as csv


@click.command()
@click.option('--raspir', '-ra', help='Name of raspir input file')
@click.option('--reporting', '-re', help='Name of reporting input file')
@click.option('--output_dir', '-d', help='The directory the file should be saved in')
@click.option('--growth_rate', '-g', help='Name of growth rate input file')
def main(raspir, reporting, output_dir, growth_rate):
    reporting_df = read_csv(reporting)
    working_df = reporting_df

    try:
        raspir_df = read_csv(raspir)
        working_df = add_raspir(raspir_df, working_df)
    except ValueError:
        warnings.warn("WARNING: problems occurred while reading raspir file. "
                      "Is there an input raspir file?")

    try:
        growth_df = read_csv(growth_rate)
        working_df = add_growth(growth_df, working_df)
    except ValueError:
        warnings.warn("WARNING: problems occurred while reading growth file. "
                      "Is there an input growth file?")

    save_csv(working_df, reporting, output_dir)


if __name__ == '__main__':
    main()
