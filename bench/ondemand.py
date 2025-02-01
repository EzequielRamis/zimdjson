import sys
import subprocess
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

better_names = {
    'simdjson_dom': 'simdjson (DOM)',
    'zimdjson_dom': 'zimdjson (DOM)',
    'yyjson': 'yyjson',
    'zimdjson_stream_dom': 'zimdjson (Streaming DOM)',
    'simdjson_ondemand': 'simdjson (On-Demand)',
    'zimdjson_ondemand': 'zimdjson (On-Demand)',
    'zimdjson_stream_ondemand': 'zimdjson (Streaming On-Demand)',
}

large_file = 'systemsPopulated' # from https://www.edsm.net/en/nightly-dumps
large_file_path = '../simdjson-data/jsonexamples/' + large_file + '.json'

twitter_benchmarks = [
    'find-tweet',
    'top-tweet',
    'partial-tweets',
]

elite_benchmarks = [
    'find-system',
    'top-factions',
    'coordinates',
]

flags = sys.argv[1:]
if '--run' in flags:
    for bench in twitter_benchmarks:
        for i in range(0, 2): # warmup
            subprocess.run("zig build bench/" + bench + " --release=fast", shell=True)
    for bench in elite_benchmarks:
        for i in range(0, 2): # warmup
            subprocess.run("zig build bench/" + bench + " --release=fast -Duse-cwd -- " + large_file_path, shell=True)

def suite_dataframe(suite, name):
    json = pd.read_json('bench/' + suite + '/results/' + name + '.json')
    data = pd.DataFrame({
        'suite': suite,
        'name': json['name'],
        'perf': json['measurements'].apply(lambda x: x['throughput']['mean'] / (1000 ** 3)), # GB/s
    })
    data['name'] = data['name'].replace(better_names)
    return data


twitter_data = pd.concat(
    map(lambda x: suite_dataframe(x, 'twitter'), twitter_benchmarks)
)

elite_data = pd.concat(
    map(lambda x: suite_dataframe(x, large_file), elite_benchmarks)
)

data = pd.concat([twitter_data, elite_data])

sns.set_theme(context="notebook", palette="bright", style="whitegrid")

g = sns.catplot(data, kind="bar", y="suite", x="perf", hue="name", legend_out=False, hue_order=better_names.values())
g.set_ylabels("")
g.set_xlabels("throughput (GB/s)")
g.legend.set_title("")

# plt.xticks(rotation=45)
plt.show()

pivot_df = data.pivot(index='suite', columns='name', values='perf')
pivot_df['relative to simdjson'] = pivot_df[better_names['simdjson_ondemand']] / pivot_df[better_names['zimdjson_ondemand']]

rel_simd = pivot_df.sort_values(by='relative to simdjson', ascending=False)
for name in better_names.values():
    if name != better_names['simdjson_ondemand'] and name != better_names['zimdjson_ondemand']:
        del rel_simd[name]

print(rel_simd)
