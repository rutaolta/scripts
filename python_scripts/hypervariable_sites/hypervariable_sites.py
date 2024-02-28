from Bio import AlignIO, SeqIO
import pandas as pd
import numpy as np

def get_hyparvariable_sites(path, count_boundary=3, frequency_boundary=0.1):
    
    def get_fasta_df(path):
        with open(path) as fasta_file:
            identifiers = []
            sequences = []
            for seq_record in SeqIO.parse(fasta_file, "fasta"):
                identifiers.append(seq_record.id)
                sequences.append(list(seq_record.seq))
            return pd.DataFrame(sequences, index=identifiers)

    df = get_fasta_df(path).replace('N', None)
    df_unique = df.apply(pd.Series.nunique)
    sites = [x[0] for x in enumerate(df_unique) 
                        if x[1] > count_boundary and x[1]/len(df) > frequency_boundary]

    info = [[site, df_unique[site], df[site].values] for site in sites]
    np.savetxt("hypervariable_sites.csv", info, delimiter ="\t", fmt ='% s')
    return sites, 'See additional info in hypervariable_sites.csv'


