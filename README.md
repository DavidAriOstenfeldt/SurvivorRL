# SurvivorRL
A test implementation of reinforcement learning in Godot 4 for a custom mande survivor game.


To run training from a binary (exported) game:
```
gdrl --env_path bin/SurvivorRL.exe --iterations 1000000 --save_every_iterations 1000000 --show_window True --speedup 16
```

To run training from the editor:
```
gdrl  --iterations 1000000 --save_every_iterations 1000000
```
