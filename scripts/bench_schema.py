#!/usr/bin/env python3

import sys
import subprocess
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

better_names = {
    'std_json': 'std.json.parseFromSlice',
    'stream_std_json': 'std.json.parseFromTokenSource',
    'serde': 'serde_json::from_str',
    'stream_serde': 'serde_json::from_reader',
    'zimdjson_ondemand': 'zimdjson (On-Demand)',
    'zimdjson_ondemand_unordered': 'zimdjson (On-Demand, Unordered)',
    'stream_zimdjson_ondemand': 'zimdjson (Streaming On-Demand)',
    'stream_zimdjson_ondemand_unordered': 'zimdjson (Streaming On-Demand, Unordered)',
    'zimdjson_schema': 'zimdjson (Schema)',
    'stream_zimdjson_schema': 'zimdjson (Streaming Schema)',
    # 'zimdjson_schema_ordered': 'zimdjson (Schema, Ordered)',
    # 'stream_zimdjson_schema_ordered': 'zimdjson (Streaming Schema, Ordered)',
}

flags = sys.argv[1:]
if '--run' in flags:
    for i in range(0, 2): # warmup
        subprocess.run("zig build bench/schema --release=fast", shell=True)

def suite_dataframe(name):
    json = pd.read_json('bench/schema/results/' + name + '.json')
    data = pd.DataFrame({
        'suite': name,
        'name': json['name'],
        'perf': json['measurements'].apply(lambda x: x['throughput']['mean'] / (1000 ** 3)), # GB/s
    })
    data['name'] = data['name'].replace(better_names)
    return data

data = suite_dataframe('twitter')

sns.set_theme(context="paper", palette="bright", style="whitegrid")

g = sns.catplot(data, kind="bar", x="suite", y="perf", hue="name", legend_out=False, hue_order=better_names.values(), height=6, aspect=1.8)
g.set_xlabels("")
g.set_ylabels("throughput (GB/s)")
g.legend.set_title("")

plt.savefig("docs/assets/bench_schema.png", dpi=300)

# plt.show()
