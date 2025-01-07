import sys
import subprocess
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

files = [
    'apache_builds',
    'canada',
    'citm_catalog',
    'github_events',
    'gsoc-2018',
    'instruments',
    'marine_ik',
    'mesh',
    'mesh.pretty',
    'numbers',
    'random',
    'twitter',
    'twitterescaped',
    'update-center',
]

better_names = {
    'zimdjson_dom': 'zimdjson (DOM)',
    'simdjson_dom': 'simdjson (DOM)',
    'yyjson': 'yyjson',
    'rapidjson_dom': 'rapidjson',
}

flags = sys.argv[1:]
if '--run' in flags:
    for file in files:
        for i in range(0, 2): # warmup
            subprocess.run("zig build bench/full-parsing --release=fast -- " + file + '.json', shell=True)

def suite_dataframe(name):
    json = pd.read_json('bench/full_parsing/results/' + name + '.json')
    data = pd.DataFrame({
        'suite': name,
        'name': json['name'],
        'perf': json['measurements'].apply(lambda x: x['throughput']['mean'] / (1000 ** 3)), # GB/s
    })
    data['name'] = data['name'].replace(better_names)
    return data

data = pd.concat(map(lambda x: suite_dataframe(x), files))

sns.set_theme(context="notebook", palette="bright", style="whitegrid")

g = sns.catplot(data, kind="bar", x="suite", y="perf", hue="name", legend_out=False)
g.set_xlabels("")
g.set_ylabels("throughput (GB/s)")
g.legend.set_title("")

plt.xticks(rotation=45)
plt.show()
