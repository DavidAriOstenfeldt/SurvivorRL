# SurvivorRL (WIP)
A test implementation of reinforcement learning in Godot 4 for a custom made survivor game.


To run training from a binary (exported) game:
```
gdrl --env_path bin/SurvivorRL.exe --iterations 1000000 --save_every_iterations 1000000 --show_window True --speedup 16
```

To run training from the editor:
```
gdrl  --iterations 1000000 --save_every_iterations 1000000
```

Args:
```
--trainer def sb3 ["sb3", "sf", "rllib"] # currently only sb3 is working
--env_path def None # path to binary (exported)
--speedup def 1 # speed up the physics of the env
--iterations def 100000 # number of iterations
--save_every_iterations def 100000 # save a model every n iterations
--save_path def "_" # the path to save the model at
--load_path def "_" # the path to load the model from
--continue_training def "true" # whether to continue training or predict with the loaded model, 
--learning_rate def 0.0003 # learning rate of the training
--show_window def True # whether or not to show the window, when using the binary
```

To test an agent
```
gdrl --env_path bin/SurvivorRL.exe --iterations 100000 --continue_training false --show_window True --speedup 1 --load_path path/to/model.zip
```
