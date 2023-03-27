import gym
import numpy as np
from stable_baselines3 import PPO
from stable_baselines3.common.vec_env.base_vec_env import VecEnv
from stable_baselines3.common.callbacks import CallbackList, EvalCallback, CheckpointCallback
from stable_baselines3.common.vec_env import VecMonitor

from godot_rl.core.godot_env import GodotEnv
from godot_rl.core.utils import lod_to_dol

import time
import yaml


class StableBaselinesGodotEnv(VecEnv):
    def __init__(self, env_path=None, **kwargs):
        self.env = GodotEnv(env_path=env_path, convert_action_space=True, **kwargs)
        self._check_valid_action_space()

        self.actions = None

    def _check_valid_action_space(self):
        action_space = self.env.action_space
        if isinstance(action_space, gym.spaces.Tuple):
            assert (
                len(action_space.spaces) == 1
            ), f"sb3 supports a single action space, this env constains multiple spaces {action_space}"

    def step(self, action):
        obs, reward, term, trunc, info = self.env.step(action)
        obs = lod_to_dol(obs)

        return {k: np.array(v) for k, v in obs.items()}, np.array(reward), np.array(term), info

    def reset(self):
        obs, info = self.env.reset()
        obs = lod_to_dol(obs)
        obs = {k: np.array(v) for k, v in obs.items()}
        return obs

    def close(self):
        self.env.close()

    def env_is_wrapped(self, wrapper, indices=None):
        return [False] * self.env.num_envs

    @property
    def observation_space(self):
        return self.env.observation_space

    @property
    def action_space(self):
        # sb3 is not compatible with tuple/dict action spaces
        return self.env.action_space

    @property
    def num_envs(self):
        return self.env.num_envs

    def env_method(self):
        raise NotImplementedError()

    def get_attr(self):
        raise NotImplementedError()

    def seed(self):
        raise NotImplementedError()

    def set_attr(self):
        raise NotImplementedError()

    def step_async(self, actions):
        self.actions = actions

    def step_wait(self):
        obs, reward, term, trunc, info = self.env.step(self.actions)
        obs = lod_to_dol(obs)


        return {k: np.array(v) for k, v in obs.items()}, np.array(reward), np.array(term), info


def stable_baselines_training(args, extras):
    # Loading hyperparameters
    if args.config_file != None:
        print(f"Loading hyperparameters from", args.config_file)
        with open(args.config_file) as f:
            file = yaml.safe_load(f)
            hparams = file["hyperparameters"]
            train_params = file["training_parameters"]

        print("Hyperparameters")
        print(hparams)
        print("Training parameters")
        print(train_params)

        # Hyper parameters
        n_steps = hparams["n_steps"]
        batch_size = hparams["batch_size"]
        gae_lambda = hparams["gae_lambda"]
        learning_rate = hparams["learning_rate"]
        gamma = hparams["gamma"]
        n_epochs = hparams["n_epochs"]
        ent_coef = hparams["ent_coef"]
        clip_range = hparams["clip_range"]

        # Training parameters
        name = train_params["name"]
        eval = train_params["eval"]
        eval_freq = train_params["eval_freq"]
        eval_render = train_params["eval_render"]
        show_window = train_params["show_window"]
        speedup = train_params["speedup"]
        eval_speedup = train_params["eval_speedup"]
        iterations = train_params["iterations"]
        export = train_params["export"]
        save_freq = train_params["save_freq"]
        save_path = train_params["save_path"]
        load_path = train_params["load_path"]
        deterministic = train_params["deterministic"]
        verbose = train_params["verbose"]
        log = train_params["log"]

    else:
        n_steps = 2048
        batch_size = 64
        gae_lambda = 0.95
        learning_rate = 0.0003
        n_epochs = 10
        gamma = 0.99
        clip_range = 0.2
        ent_coef = 0.0

        name = "PPO"
        eval = true
        eval_freq = 10000
        eval_render = False
        eval_speedup = 16
        show_window = True
        speedup = 16
        iterations = 1000000
        save_freq = 100000
        verbose = 1
        save_path = "save/models"
        load_path = "_"
        deterministic = False
        export = True
        log = True

    # Override deterministic with arg (to enable prediction without changing config file)
    if args.deterministic:
        deterministic = args.deterministic

    # Override speedup with arg (quick way instead of changing config file)
    if args.speedup != None:
        speedup = args.speedup
        eval_speedup = args.speedup

    # Override load path with arg (quick way instead of changing config file)
    if args.load_path != None and load_path != "_":
        load_path = args.load_path

    # Override eval with arg (allows training in editor without changing config)
    if args.noeval:
        eval = False

    env = StableBaselinesGodotEnv(env_path=args.env_path, show_window=show_window, speedup=speedup)

    eval_freq = int(eval_freq / env.num_envs)

    #env = VecMonitor(env, "logs/monitor")
    if eval:
        eval_env = StableBaselinesGodotEnv(env_path=args.env_path, show_window=eval_render, speedup=eval_speedup)
        eval_callback = EvalCallback(eval_env, best_model_save_path=save_path, log_path=save_path,
                                     deterministic=True, render=eval_render, eval_freq=eval_freq, warn=False)
        #eval_env = VecMonitor(eval_env, "logs/monitor")
    if export:
        save_freq = int(save_freq / env.num_envs)
        checkpoint_callback = CheckpointCallback(save_freq=save_freq, save_path=save_path, name_prefix=name,
                                             save_replay_buffer=True, save_vecnormalize=True)



    if load_path != "_" and deterministic:
        model = PPO.load(load_path, env)
    else:
        if log:
            model = PPO(
                "MultiInputPolicy",
                env,
                batch_size=batch_size,
                ent_coef=ent_coef,
                verbose=verbose,
                n_steps=n_steps,
                n_epochs=n_epochs,
                tensorboard_log="logs/log",
                learning_rate=learning_rate,
                gae_lambda=gae_lambda,
                clip_range=clip_range,
                gamma=gamma
            )
        else:
            model = PPO(
                "MultiInputPolicy",
                env,
                batch_size=batch_size,
                ent_coef=ent_coef,
                verbose=verbose,
                n_steps=n_steps,
                n_epochs=n_epochs,
                learning_rate=learning_rate,
                gae_lambda=gae_lambda,
                clip_range=clip_range,
                gamma=gamma
            )

    if not deterministic:
        if export and eval:
            print("Export and eval set to true")
            callback = CallbackList([checkpoint_callback, eval_callback])
        elif export and not eval:
            print("Export set to true")
            callback = checkpoint_callback
        elif eval and not export:
            print("Eval set to true")
            callback = eval_callback
        else:
            print("No export and no eval")
            callback = []

        model.learn(iterations, callback=callback, progress_bar=True)
    else:
        print("Testing model", load_path)
        obs = env.reset()
        for i in range(iterations):
            action, _states = model.predict(obs, deterministic=True)
            obs, rewards, dones, info = env.step(action)

    print("closing env")
    env.close()
