"""
This is the main entrypoint to the Godot RL Agents interface

Example usage is best found in the documentation: 
https://github.com/edbeeching/godot_rl_agents/blob/main/docs/EXAMPLE_ENVIRONMENTS.md

Hyperparameters and training algorithm can be defined in a .yaml file, see ppo_test.yaml as an example.


Interactive Training:
With the Godot editor open, type gdrl in the terminal to launch training and 
then press PLAY in the Godot editor. Training can be stopped with CTRL+C or
by pressing STOP in the editor.


Training with an exported executable:

gdrl --env_path path/to/exported/executable ---config_path path/to/yaml/file


"""

import argparse

try:
    from godot_rl.wrappers.ray_wrapper import rllib_training
except ImportError as e:
    def rllib_training(args, extras):
        print("Import error when trying to use rllib, this is probably not installed try pip install godot-rl[rllib]")

try:
    from godot_rl.wrappers.stable_baselines_wrapper import \
        stable_baselines_training
except ImportError as e:
    def stable_baselines_training(args, extras):
        print(
            "Import error when trying to use sb3, this is probably not installed try pip install godot-rl[sb3]"
        )
try:
    from godot_rl.wrappers.sample_factory_wrapper import \
        sample_factory_training, sample_factory_enjoy
except ImportError as e:

    def sample_factory_training(args, extras):
        print(
            "Import error when trying to use sample-factory, this is probably not installed try pip install godot-rl[sf]"
        )


def get_args():
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument(
        "--trainer",
        default="sb3",
        choices=["sb3", "sf", "rllib"],
        type=str,
        help="Which trainer framework to use (stable-baselines)",
    )
    parser.add_argument(
        "--env_path",
        # default="envs/example_envs/builds/JumperHard/jumper_hard.x86_64",
        default=None,
        type=str,
        help="The Godot binary to use, do not include for in editor training",
    )
    parser.add_argument(
        "--config_file",
        default="ppo-hparams.yaml",
        type=str,
        help="The yaml config file used to specify parameters for training",
    )
    parser.add_argument(
        "--deterministic",
        action='store_true',
        help="Overrides config. Whether to predict (test) or train the model"
    )
    # parser.add_argument(
    #     "--restore",
    #     default=None,
    #     type=str,
    #     help="the location of a checkpoint to restore from",
    # )
    parser.add_argument(
        "--speedup",
        type=int,
        help="Optional: Overrides config. Whether to speed up the physics in the env",
    )
    parser.add_argument(
        "--noeval",
        action='store_true',
        help="Overrides config. When set, model won't evaluate (required for in editor training)"
    )
    # parser.add_argument(
    #     "--iterations",
    #     default=100000,
    #     type=int,
    #     help="number of iterations to run for (sb3)",
    # )
    # parser.add_argument(
    #     "--save_every_iterations",
    #     default=100000,
    #     type=int,
    #     help="After every how many iterations to save model",
    # )
    # parser.add_argument(
    #     "--save_path",
    #     default="_",
    #     type=str,
    #     help="Location of save path, example: save/model"
    # )
    parser.add_argument(
        "--load_path",
        type=str,
        help="Where to load model from, same as save_path"
    )
    # parser.add_argument(
    #     "--continue_training",
    #     default="true",
    #     type=str,
    #     help="Whether to continue training or be deterministic (Only if --load_path is specified)"
    # )
    # parser.add_argument(
    #     "--log",
    #     default="true",
    #     type=str,
    #     help="Log?"
    # )
    # parser.add_argument(
    #     "--export",
    #     default=False,
    #     action="store_true",
    #     help="whether to export the model"
    # )
    # parser.add_argument(
    #     "--num_gpus",
    #     default=None,
    #     type=int,
    #     help="Number of GPUs to use [only for rllib]"
    # )
    # parser.add_argument(
    #     "--verbose",
    #     default=1,
    #     type=int,
    #     help="default 1, [0, 1, 2], 0: no output. 1: information about training. 2: detailed information about training"
    # )
    # parser.add_argument(
    #     "--learning_rate",
    #     default=0.0003,
    #     type=float,
    #     help="Learning Rate"
    # )
    # parser.add_argument(
    #     "--show_window",
    #     default=True,
    #     type=bool,
    #     help="Show game window during training True/False"
    # )
    # parser.add_argument(
    #     "--eval_freq",
    #     default=10000,
    #     type=int,
    #     help="How often to evaluate the model"
    # )
    # parser.add_argument(
    #     "--eval_render",
    #     default=False,
    #     type=bool,
    #     help="Whether to render the evaluation True/False"
    # )
    
    return parser.parse_known_args()


def main():
    args, extras = get_args()
    print(args)
    if args.trainer == "rllib":
        training_function = rllib_training
    elif args.trainer == "sb3":
        training_function = stable_baselines_training
    elif args.trainer == "sf":
        if args.eval:
            training_function = sample_factory_enjoy
        else:
            training_function = sample_factory_training
    else:
        raise NotImplementedError

    training_function(args, extras)


if __name__ == "__main__":
    main()
