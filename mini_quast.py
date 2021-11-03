import os
import pandas as pd
import numpy as np


def split_fasta(input, window_size=10_000):

    path, filename = os.path.split(input)
    newfilename = '%s_splitted.csv' % os.path.splitext(filename)[0]
    output = os.path.join(path, newfilename)

    with open(input) as file:

        seq_iter = map(lambda seq: seq.split("\n", 1), file.read().split(">"))
        next(seq_iter)

        data = []
        while True:
            try:
                seq = next(seq_iter)

                scaffold = seq[0].split(" ", 1)[0]
                info = seq[0]
                sequence = ''.join(seq[1].splitlines())

                data.append([scaffold, sequence, info])
            except StopIteration:
                break

        df = pd.DataFrame(data, columns=['scaffold_name', 'sequence' , 'info'])
        df.to_csv(output, index=False)
    return df


def get_scaffolds_length(scaffolds):
    return np.array(map(lambda scaffold: len(scaffold), scaffolds))


def get_scaffolds_N_count(scaffolds):
    return np.array(map(lambda scaffold: get_N_cnt(scaffold), scaffolds))


def get_scaffolds_GC_content(scaffolds, window_size=10_000):
    return np.array(map(lambda scaffold: np.mean(get_GC_content(seq=scaffold, window=window_size)), scaffolds))


def get_genome_len(lenghts):
    return np.sum(lenghts)


def get_max_scaffold_len(lenghts):
    return np.max(lenghts)


def get_scaffold_cnt(df):
    return len(df)


def N50_L50(lenghts, genome_size, statictic='N'):
    sorted_lenghts = sorted(lenghts, reverse=True)
    cumsum_lenghts = np.cumsum(sorted_lenghts)
    half_genome = genome_size//2
    
    min_fit_cumsum=cumsum_lenghts[cumsum_lenghts >= half_genome][0]
    index = np.where(cumsum_lenghts == min_fit_cumsum)[0][0]

    return index + 1 if statictic == 'L' else sorted_lenghts[index]


def get_N50(lenghts):
    return N50_L50(lenghts, np.sum(lenghts), 'N')


def get_L50(lenghts):   
    return N50_L50(lenghts, np.sum(lenghts), 'L')


def get_NG50(lenghts, genome_size):
    return N50_L50(lenghts, genome_size, 'N')


def get_N_cnt(sequence):
    return sequence.count('N')   


def GC(seq):
    gc = sum(seq.count(x) for x in ["G", "C", "g", "c", "S", "s"])
    try:
        return gc * 100.0 / len(seq)
    except ZeroDivisionError:
        return 0.0


def get_GC_content(seq, window=50_000):
    values = []
    for i in range(0, len(seq), window):
        values.append(GC(seq[i : i + window]))
    return values

