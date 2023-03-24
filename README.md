# SurvivorRL (WIP)
A test implementation of reinforcement learning in Godot 4 for a custom made survivor game.


To run training from a binary (exported) game:
```
gdrl --env_path bin/SurvivorRL.exe --config_path ppo-hparams.yaml
```

To run training from the Godot 4 editor:
```
gdrl --noeval
```
and then press play in the editor.


Hyper- and training-parameters can be modified in `ppo-hparams.yaml`.

To test a stored model, adjust `ppo-hparams.yaml` values:

* `deterministic: True`
* `load_path: path/to/model`

Or run with:
```
gdrl --env_path bin/SurvivorRL.exe --config_path ppo-hparams.yaml --deterministic
```
