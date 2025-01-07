import sys
import subprocess
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

files = [
    'twitter',
    'citm_catalog',
    'semanticscholar-corpus',
    'systemsWithCoordinates7days',
    'systemsWithoutCoordinates',
    'systemsPopulated',
    'bodies7days',
    'codex',
]

better_names = {
    'zimdjson_dom': 'zimdjson (DOM)',
    'simdjson_dom': 'simdjson (DOM)',
    'yyjson': 'yyjson',
    'rapidjson_dom': 'rapidjson',
    'zimdjson_stream_dom': 'zimdjson (Streaming DOM)',
    'rapidjson_stream': 'rapidjson (FileReadStream)',
}

better_suites = {
    'twitter': 'twitter\n(632k)',
    'citm_catalog': 'citm_catalog\n(1.7M)',
    'semanticscholar-corpus': 'semanticscholar-corpus\n(8.6M)',
    'systemsWithCoordinates7days': 'systemsWithCoordinates7days\n(28M)',
    'systemsWithoutCoordinates': 'systemsWithoutCoordinates\n(132M)',
    'systemsPopulated': 'systemsPopulated\n(626M)',
    'bodies7days': 'bodies7days\n(1.4G)',
    'codex': 'codex\n(2.7G)',
}

prefix = '../simdjson-data/jsonexamples' # edit it for convenience
flags = sys.argv[1:]
if '--run' in flags:
    for file in files:
        for i in range(0, 2): # warmup
            subprocess.run("zig build bench/streaming --release=fast -Duse-cwd -- " + prefix + '/' + file + '.json', shell=True)

def suite_dataframe(name):
    json = pd.read_json('bench/streaming/results/' + name + '.json')
    data = pd.DataFrame({
        'suite': name,
        'name': json['name'],
        'perf': json['measurements'].apply(lambda x: x['throughput']['mean'] / (1000 ** 3)), # GB/s
    })
    data['suite'] = data['suite'].replace(better_suites)
    data['name'] = data['name'].replace(better_names)
    return data

data = pd.concat(map(lambda x: suite_dataframe(x), files))

sns.set_theme(context="notebook", palette="bright", style="whitegrid")

g = sns.catplot(data, kind="bar", y="suite", x="perf", hue="name", legend_out=False)
g.set_ylabels("")
g.set_xlabels("throughput (GB/s)")
g.legend.set_title("")

# plt.xticks(rotation=45)
plt.show()
