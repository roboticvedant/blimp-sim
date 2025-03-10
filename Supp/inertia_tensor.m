clear; clc; close all;
radius_baloon = 0.3; % in m
mylar_thickness = 35e-6;

p = 101325;              % Pressure in Pascals (1 atm)
T = 293.15;              % Temperature in Kelvin (approximately 20°C)
M_He = 4.002602e-3;         % Molar mass of Helium in kg/mol
R = 8.314;               % Universal gas constant in J/(mol·K)
density_of_helium = (p * M_He) / (R * T);
volume_helium = (4/3)*pi*(radius_baloon-mylar_thickness)^3;
mass_helium = volume_helium*density_of_helium; % mass in kg

density_of_mylar = 1410;
volume_material = (4/3)*pi*(radius_baloon^3 - (radius_baloon-mylar_thickness)^3);
mass_mylar = volume_material*density_of_mylar;
% mass_mylar = 55e-3;

Ibaloon_he = eye(3) * (2/5) * mass_helium * radius_baloon^2; % about center of baloon
Ibaloon_mylar = eye(3) * (2/3) * mass_mylar * radius_baloon^2; % about center of baloon
Ibaloon = Ibaloon_he + Ibaloon_mylar;

%Shift Inertia tensor to COM

vec_from_COM_to_COB = [0; 0; radius_baloon]; % assuming gondola height is small enough

I_baloon_COM = Ibaloon + mass_helium* ... 
    (eye(3)*norm(vec_from_COM_to_COB)^2 - vec_from_COM_to_COB*vec_from_COM_to_COB');

I_gondola = [1.078e5 495.763 1937.146;
            495.763 1.236e5 -1835.888;
            1937.146 -1835.888 76262.526]*1e-9;

I_tensor = I_gondola+I_baloon_COM
