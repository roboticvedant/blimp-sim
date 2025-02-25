clear; close all; clc;
addpath("Functions/")
%% Define Simulation Parameters
% Time settings
t_start = 0;          % Start time
t_end = 5;          % End time
tspan = [t_start t_end];

% Initialize state vector
n = 12;               % Number of states
x0 = zeros(n,1);        % Initial conditions - replace with your initial states
% x0(1:3) = [5;0;6]
% x0(10:12) = [0.05; 0.05; 0.05];  % Small nonzero angular velocity

global debug;
debug = struct();

% Initialize debug fields to empty arrays
debug.v2 = [];
debug.Fb_xu = [];
debug.Fthruster = [];
debug.Fgravity = [];
debug.Fboyant = [];
debug.Faero = [];
debug.Mb_xu = [];
debug.Mthruster = [];
debug.Maero = [];
debug.attack_angle = [];
debug.sideslip_angle = [];
debug.Cd = [];
debug.Cs = [];
debug.Cl = [];
debug.Cm1 = [];
debug.Cm2 = [];
debug.Cm3 = [];
debug.D = [];
debug.S = [];
debug.L = [];
debug.M1 = [];
debug.M2 = [];
debug.M3 = [];

% add debug.v2 from the state eq calc to see 
global param
param = init_params();

% Add more parameters as needed
%% Solve using ode45
% Set ODE options if needed
options = odeset('RelTol', 1e-4, 'AbsTol', 1e-6);


[t, x] = ode45(@state_equations, tspan, x0, options);

figure;
plot3(x(:,1),x(:,2),x(:,3))
grid on;
title("Trajectory of Blimp")

real_time_plot(t, x);

