import numpy as np
import matplotlib.pyplot as plt
import argparse
plt.style.use('seaborn-darkgrid')




def get_args():
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument("--file_path", default="save/models/evaluations.npz", type=str, help="The path to evaluations.npz")
    
    return parser.parse_known_args()


args, extras = get_args()

evaluations = np.load(args.file_path)

episode_lengths = evaluations.f.ep_lengths
results = evaluations.f.results
timesteps = evaluations.f.timesteps

conf_int = np.std(results, axis=1)
mean_results = np.mean(results, axis=1)

mean_episode_lengths = np.mean(episode_lengths, axis=1)
conf_int_ep = np.std(episode_lengths, axis=1)


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 5))
ax1.set_title("Avg. Rewards per Timestep")
ax1.set_xlabel("Timesteps (in million)")
ax1.set_ylabel("Avg. Rewards")
ax1.plot(timesteps, mean_results)
ax1.fill_between(timesteps, (mean_results-conf_int), (mean_results + conf_int), alpha=.25)

ax2.set_title("Avg. Episode Length per Timestep")
ax2.plot(timesteps, mean_episode_lengths)
ax2.set_xlabel("Timesteps (in million)")
ax2.set_ylabel("Avg. Episode Lengths")
ax2.fill_between(timesteps, (mean_episode_lengths-conf_int_ep), (mean_episode_lengths + conf_int_ep), alpha=.25)

plt.tight_layout()
plt.savefig("plotting/evaluations.png")


