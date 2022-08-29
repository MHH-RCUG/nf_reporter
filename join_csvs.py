# Script to combine reporting, growth_rate and raspir output
# Lisa Hollstein, Feb-Aug 2022
# Janno Peilert, Aug 2022


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
    df["growth_class"] = "no_growth_class"
    df["growth_rate"] = "no_growth_rate"
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


def extract_species_name(df):
    df["species_kraken"] = ""
    rownames = df["species"]
    for row in rownames:
        split_name = row.split("_")
        for n in range(len(split_name)):
            try:  # Using Unicode to find the species
                # The species name consists of at least two words: generic and specific name.
                # The first word starts with a capital letter
                first_letter = ord(split_name[n][0])  # must be a capital letter
                second_letter = ord(split_name[n][1])  # must be a lowercase letter
                second_first = ord(split_name[n + 1][0])  # must be a lowercase letter
                # Unicode value of lowercase letters is between 97 and 122, for capital letters it is between 65 and 90
                if 64 < first_letter < 91 and 96 < second_letter < 123 and 96 < second_first < 123:
                    new_name = split_name[n] + " " + split_name[n + 1]
                    # add extracted species name
                    df.loc[df["species"] == row, "species_kraken"] = new_name
                    break
            except:
                pass
    return df


def add_kraken(kraken_df, df):
    kraken_df = kraken_df[kraken_df["rank"] == "species"]

    #create new columns
    df["krakenuniq_reads"] = "not_in_kraken"
    df["krakenuniq_%"] = "not_in_kraken"
    df["krakenuniq_taxReads"] = "not_in_kraken"

    # sorts rows with reads less then 20 out
    # TODO 20 in variable
    kraken_df = kraken_df.drop(kraken_df[kraken_df.reads < 20].index)

    #checks if species found in Wochenende were found by kraken
    for species_k in kraken_df["taxName"]:
        # clears whitespaces
        species = species_k.lstrip(" ")

        if (species in df["species_kraken"].values):
            df.loc[df["species_kraken"] == species, "krakenuniq_reads"] = kraken_df.loc[
                kraken_df["taxName"] == species_k, "reads"].values[0]
            
        else:
            df.loc[df.shape[0]] = "not_in_we"
            df.loc[df.index[-1], "species_kraken"] = species
            df.loc[df.index[-1], "krakenuniq_reads"] = kraken_df.loc[
                kraken_df["taxName"] == species_k, "reads"].values[0]

        #select columns from krakentable
        df.loc[df["species_kraken"] == species, "krakenuniq_%"] = kraken_df.loc[
            kraken_df["taxName"] == species_k, "%"].values[0]
        df.loc[df["species_kraken"] == species, "krakenuniq_taxReads"] = kraken_df.loc[
            kraken_df["taxName"] == species_k, "taxReads"].values[0]

    #print(df)
    return df


def save_csv(df, reporting):
    save_name = os.path.basename(reporting) + ".nf_reporting.csv"  # set save name
    df.to_csv(save_name, sep=",", index=False)  # save as csv


@click.command()
@click.option('--raspir', '-ra', help='Name of raspir input file')
@click.option('--reporting', '-re', help='Name of reporting input file')
@click.option('--growth_rate', '-g', help='Name of growth rate input file')
@click.option('--kraken', '-k', help='Name of kraken input file')

def main(raspir, reporting, growth_rate, kraken):
    reporting_df = read_csv(reporting)
    all_df = reporting_df

    try:
        raspir_df = read_csv(raspir)
        all_df = add_raspir(raspir_df, all_df)
    except ValueError:
        warnings.warn("WARNING: problems occurred while reading raspir file. "
                      "Is there an input raspir file?")

    try:
        growth_df = read_csv(growth_rate)
        all_df = add_growth(growth_df, all_df)
    except ValueError:
        warnings.warn("WARNING: problems occurred while reading growth file. "
                      "Is there an input growth file?")

    try:
        kraken_df = pd.read_csv(kraken, sep="\t", skiprows=3)
        all_df = extract_species_name(all_df)
        all_df = add_kraken(kraken_df, all_df)
    except ValueError:
        print("INFO: No kraken file found for", reporting, "or error during adding of kraken information")

    save_csv(all_df, reporting)
    #print(all_df)


if __name__ == '__main__':
    main()
