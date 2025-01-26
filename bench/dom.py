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
    'simdjson_dom': 'simdjson (DOM)',
    'zimdjson_dom': 'zimdjson (DOM)',
    'yyjson': 'yyjson',
    'rapidjson_dom': 'rapidjson',
}

flags = sys.argv[1:]
if '--run' in flags:
    for file in files:
        for i in range(0, 2): # warmup
            subprocess.run("zig build bench/dom --release=fast -- " + file + '.json', shell=True)

def suite_dataframe(name):
    json = pd.read_json('bench/dom/results/' + name + '.json')
    data = pd.DataFrame({
        'suite': name,
        'name': json['name'],
        'perf': json['measurements'].apply(lambda x: x['throughput']['mean'] / (1000 ** 3)), # GB/s
    })
    data['name'] = data['name'].replace(better_names)
    return data

data = pd.concat(map(lambda x: suite_dataframe(x), files))

sns.set_theme(context="notebook", palette="bright", style="whitegrid")

g = sns.catplot(data, kind="bar", y="suite", x="perf", hue="name", legend_out=False, hue_order=better_names.values())
g.set_ylabels("")
g.set_xlabels("throughput (GB/s)")
g.legend.set_title("")

# plt.xticks(rotation=45)
plt.show()

pivot_df = data.pivot(index='suite', columns='name', values='perf')
del pivot_df[better_names['rapidjson_dom']]
pivot_df['relative to simdjson'] = pivot_df[better_names['simdjson_dom']] / pivot_df[better_names['zimdjson_dom']]
pivot_df['relative to yyjson'] = pivot_df[better_names['yyjson']] / pivot_df[better_names['zimdjson_dom']]

rel_simd = pivot_df.sort_values(by='relative to simdjson', ascending=False)
del rel_simd[better_names['yyjson']]
del rel_simd['relative to yyjson']
print(rel_simd)

rel_yy = pivot_df.sort_values(by='relative to yyjson', ascending=False)
del rel_yy[better_names['simdjson_dom']]
del rel_yy['relative to simdjson']
print(rel_yy)
