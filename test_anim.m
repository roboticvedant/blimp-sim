clc; clear; close all;

%% Initialize Simulation Parameters
t_start = 0;
t_end = 60;
dt = 0.01;  % Smaller time step
t = t_start:dt:t_end;

% Initialize state vector
n = 12;
x0 = zeros(n,1);
% x0(1:3) = [5;0;6] % Uncomment to set initial position

global param
param = init_params();

% Solve ODE with more conservative tolerances and smaller max step
options = odeset('RelTol', 1e-6, ...
                'AbsTol', ones(1,n)*1e-6, ...
                'MaxStep', 0.01, ...
                'InitialStep', 0.001);
[t, x] = ode45(@state_equations, t, x0, options);

%% Create 3D World in Unreal Engine
world = sim3d.World();

% Create ground
ground = sim3d.Actor(ActorName='Ground');
createShape(ground, 'plane', [100, 100, 0]); % 100x100 meters plane
ground.Color = [0.5, 0.5, 0.5]; % Gray color
add(world, ground);

% Create sphere for quadrotor body
sphere = sim3d.Actor(ActorName='QuadrotorBody');
createShape(sphere, 'sphere', 0.3); % 0.3m radius sphere
sphere.Color = [0.8, 0.8, 1.0]; % Light blue color
add(world, sphere);

% Create body-fixed frame axes using cylinders
% X-axis (Red)
body_x = sim3d.Actor(ActorName='BodyX');
createShape(body_x, 'cylinder', [0.05, 1]); % radius, length
body_x.Color = [1, 0, 0];
add(world, body_x);

% Y-axis (Green)
body_y = sim3d.Actor(ActorName='BodyY');
createShape(body_y, 'cylinder', [0.05, 1]);
body_y.Color = [0, 1, 0];
add(world, body_y);

% Z-axis (Blue)
body_z = sim3d.Actor(ActorName='BodyZ');
createShape(body_z, 'cylinder', [0.05, 1]);
body_z.Color = [0, 0, 1];
add(world, body_z);

% Create inertial frame at origin (using cylinders)
% X-axis (Red)
inertial_x = sim3d.Actor(ActorName='InertialX');
createShape(inertial_x, 'cylinder', [0.05, 2]); % Thicker and longer
inertial_x.Color = [0.8, 0, 0];
inertial_x.Position = [1, 0, 0];
inertial_x.Orientation = quaternion([0, 0, 90], 'eulerd', 'XYZ', 'frame');
add(world, inertial_x);

% Y-axis (Green)
inertial_y = sim3d.Actor(ActorName='InertialY');
createShape(inertial_y, 'cylinder', [0.05, 2]);
inertial_y.Color = [0, 0.8, 0];
inertial_y.Position = [0, 1, 0];
add(world, inertial_y);

% Z-axis (Blue)
inertial_z = sim3d.Actor(ActorName='InertialZ');
createShape(inertial_z, 'cylinder', [0.05, 2]);
inertial_z.Color = [0, 0, 0.8];
inertial_z.Position = [0, 0, 1];
inertial_z.Orientation = quaternion([90, 0, 0], 'eulerd', 'XYZ', 'frame');
add(world, inertial_z);

% Set up camera
camera = sim3d.Camera(ActorName='MainCamera');
camera.Position = [5, 5, 3];
camera.LookAt = [0, 0, 0];
add(world, camera);

% Define sample time
sampleTime = 0.02; % 50 Hz update rate

% Create animation callback function
function updateVisualization(t_current)
    % Find closest time index
    [~, idx] = min(abs(t - t_current));
    
    % Get current state
    position = x(idx, 1:3);
    euler = x(idx, 4:6);
    
    % Update sphere position and orientation
    sphere.Position = position;
    sphere.Orientation = euler2quat(euler, 'XYZ');
    
    % Update body frame axes
    % Calculate rotation matrix
    R = eul2rotm(euler, 'XYZ');
    
    % Update body frame axes positions and orientations
    % X-axis
    body_x.Position = position + R(:,1)'/2; % Center the cylinder
    body_x.Orientation = euler2quat(euler, 'XYZ');
    
    % Y-axis
    body_y.Position = position + R(:,2)'/2;
    body_y.Orientation = quaternion([euler(1), euler(2), euler(3)+90], 'eulerd', 'XYZ', 'frame');
    
    % Z-axis
    body_z.Position = position + R(:,3)'/2;
    body_z.Orientation = quaternion([euler(1)+90, euler(2), euler(3)], 'eulerd', 'XYZ', 'frame');
end

% Run simulation
disp('Starting Unreal Engine simulation...');
run(world, sampleTime, t_end, @updateVisualization);