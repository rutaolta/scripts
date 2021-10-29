from os import mkdir
import pandas as pd
import numpy as np


def get_fasta_info(input, output, window_size=10_000):
    with open(input) as file:

        seq_iter = map(lambda seq: seq.split("\n", 1), file.read().split(">"))
        next(seq_iter)

        data = []
        while True:
            try:
                seq = next(seq_iter)

                scaffold = seq[0].split(" ", 1)[0]
                info = seq[0]
                sequence = seq[1]
                n_count = get_N_cnt(sequence)    
                gc_content = np.mean(get_GC_content(seq=sequence, window=window_size))

                data.append([scaffold, len(sequence), n_count, gc_content, info])
            except StopIteration:
                break

        df = pd.DataFrame(data, columns=['scaffold_name', 'scaffold_length', 'n_count', 'gc_content', 'info'])
        df.to_csv(output, index=False)
    return df


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


def test(input='scripts/saccharomyces_cerevisiae.fasta', output='scripts/fasta_info.csv'):
    df = get_fasta_info(input, output)
    print("Genome length: ", get_genome_len(df['scaffold_length']))
    print("Max scaffold length: ", get_max_scaffold_len(df['scaffold_length']))
    print("Scaffold count: ", get_scaffold_cnt(df))
    print("N50: ", get_N50(df['scaffold_length']))
    print("L50: ", get_L50(df['scaffold_length']))
    print("NG50: ", get_NG50(df['scaffold_length'], genome_size=12_242_942))

