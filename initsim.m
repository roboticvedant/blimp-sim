% All constant params for the simulink
clear; clc;
param = init_params();
Simulink.Bus.createObject(param);
