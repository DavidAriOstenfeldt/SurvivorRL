# SurvivorRL (WIP)
A test implementation of reinforcement learning in Godot 4 for a custom made survivor game.


To run training from a binary (exported) game:
```
gdrl --env_path bin/SurvivorRL.exe --config_path ppo-hparams.yaml
```

To run training from the editor:
```
gdrl
```

Hyper- and training-parameters can be modified in `ppo-hparams.yaml`.

To test a stored model, adjust `ppo-hparams.yaml` values:

* `deterministic: True`
* `load_path: path/to/model`

