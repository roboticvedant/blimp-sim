% All constant params for the simulink
clear; clc;
addpath("Functions/")
param = init_params();
[Forces, Moments] = forces_moments_struct();

Simulink.Bus.createObject(param);
Simulink.Bus.createObject(Forces);
Simulink.Bus.createObject(Moments);

