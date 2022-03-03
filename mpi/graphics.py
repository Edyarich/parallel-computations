from matplotlib import pyplot as plt
import pandas as pd

data = pd.read_csv("data.txt", sep=' ', header=None, names=['proc_cnt', 'N', 'S'])
plt.figure(figsize=(10, 5))
ax = plt.gca()

data.groupby('N').plot.line(x='proc_cnt',
                            y='S',
                            ax=ax,
                            lw=2,
                            legend=False,
                            xlabel="Process count",
                            ylabel = "Speedup")

current_handles, _ = plt.gca().get_legend_handles_labels()

plt.legend(current_handles, ["N = 1000", "N = 1'000'000", "N = 100'000'000"])
plt.grid(True)
plt.show()

plt.savefig('graphic.png')