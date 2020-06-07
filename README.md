# DinosaurRun

## A project for university

A simple game and game controller, which uses evolutionary algorithms to play the game.

Currently it uses NEAT and HyperNEAT algorithms to find a playable strategy through the process of natural selection.

## Usage

Most important settings for experiments can be changed in `DinosaurRun.pde` file.

- `isShowingUI` - toggles the UI
- `isRunningNEAT` - true for NEAT exsperiment, false for HyperNEAT
- `experimentType` - enumerator for experiment limitations (`ExperimentType.Time` or `ExperimentType.Generations`)
