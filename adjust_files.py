# Lisa Hollstein, March 2022

import click
import pandas as pd


@click.command()
@click.option('--input_file', '-f', help='Name of file to be adjusted')
@click.option('--column', '-c', help='Column after which data gets selected')
@click.option('--growth_class', help='If column=growth_class select which class should be used')
def main(input_file, column, growth_class):
    df = pd.read_csv(input_file)
    if column == "raspir":
        df = df[df["raspir"] == "raspir_positive"]
        df.drop(columns=["raspir", "growth_class", "growth_rate"], inplace=True, errors="ignore")
    elif column == "growth":
        print(growth_class)
    df.to_csv(input_file + ".rasp.csv", sep=",", index=False)


if __name__ == '__main__':
    main()
