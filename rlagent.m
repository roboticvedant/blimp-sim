clc; close all;

obsInfo = rlNumericSpec([12 1]);
actionInfo = rlNumericSpec([4 1]);

agent = rlDDPGAgent(obsInfo,actionInfo)

env = rlSimulinkEnv('blimp_state_space','blimp_state_space/RL Agent', obsInfo, actionInfo, 'UseFastRestart', 'off')

options = rlTrainingOptions(...
    "MaxEpisodes",1000, ...
    "MaxStepsPerEpisode",500, ...
    "ScoreAveragingWindowLength",10, ...
    "Verbose",true,...
    "Plots",'training-progress');

trainingStats = train(agent, env, options)

