import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
import sys

files = sys.argv[1:-1]
renames = sys.argv[-1]

with open("txt.txt", "w") as file:
    file.write(str(files))

stats_dict = defaultdict(list)
for file in files:
    with open(file) as file:
        content = file.readlines()
        for line in content[7:45]:
            line = line.strip('\n').split('\t')
            stats_dict[line[1]].append(float(line[2]))

rename = {num: name for (num, name) in enumerate(renames)}
stats = pd.DataFrame.from_dict(stats_dict)
stats = stats.rename(index=rename)

stats

plt.rcParams["figure.figsize"] = [10, 5]
plt.rcParams["figure.autolayout"] = True
plt.rcParams.update({'font.size': 15})

cols = ['reads mapped:', 'reads unmapped:']
stats[cols].plot(kind='bar')
# plt.yscale('log')
plt.ylabel('Number of reads')
plt.xlabel('sample names')
plt.title('Read alignment per sample')
plt.xticks(rotation=30, ha='right')
plt.legend(loc='upper left')
plt.savefig(f"{renames}_read_alignments.png", dpi=200)

stats['mismatches:'].plot(kind='bar')
# plt.yscale('log')
plt.ylabel('Number of bases')
plt.xlabel('sample names')
plt.title('Mismatches per sample')
plt.xticks(rotation=30, ha='right')
plt.savefig(f"{renames}_read_mismatches.png", dpi=200)

stats['average length:'].plot(kind='bar')
plt.ylabel('Number of bases')
plt.xlabel('sample names')
plt.title('Average read length per sample')
plt.xticks(rotation=30, ha='right')
plt.savefig(f"{renames}_read_lengths.png", dpi=200)

sys.exit(0)