clear; close all; clc;
addpath("Functions/")
%% Define Simulation Parameters
% Time settings
t_start = 0;          % Start time
t_end = 20;          % End time
tspan = [t_start t_end];

% Initialize state vector
n = 12;               % Number of states
x0 = zeros(n,1);        % Initial conditions - replace with your initial states
% x0(1:3) = [5;0;6]
global param
param = init_params();

% Add more parameters as needed
%% Solve using ode45
% Set ODE options if needed
options = odeset('RelTol', 1e-6, 'AbsTol', 1e-8);

[t, x] = ode45(@state_equations, tspan, x0, options);

figure;
plot3(x(:,1),x(:,2),x(:,3))
grid on;
title("Trajectory of Blimp")

real_time_plot(t, x);

