clear; clc; close all;
COM_O = [40.975; 21.642; -49.856];
thrusterP_O = [0.5; 0; 0] - COM_O;
thrusterQ_O = [80.5; 0; 0] - COM_O;
thrusterR_O = [16.593; 1.50; -5.00] - COM_O;
thrusterS_O = [64.407; 1.50; -5.00] - COM_O;

RCOM_CAD = [0 0 -1;
            -1 0 0;
            0 1 0];
% Points (unit m) in COM ref frame
thrusterP_O = 1e-3.*RCOM_CAD*thrusterP_O;
thrusterQ_O = 1e-3.*RCOM_CAD*thrusterQ_O;
thrusterR_O = 1e-3.*RCOM_CAD*thrusterR_O;
thrusterS_O = 1e-3.*RCOM_CAD*thrusterS_O;

% Plot thruster points
figure;
scatter3(0, 0, 0, 100, 'r', 'filled', 'DisplayName', 'COM-body fixed frame');
hold on;
scatter3(thrusterP_O(1), thrusterP_O(2), thrusterP_O(3), 100, 'r', 'filled', 'DisplayName', 'Thruster P');
scatter3(thrusterQ_O(1), thrusterQ_O(2), thrusterQ_O(3), 100, 'g', 'filled', 'DisplayName', 'Thruster Q');
scatter3(thrusterR_O(1), thrusterR_O(2), thrusterR_O(3), 100, 'b', 'filled', 'DisplayName', 'Thruster R');
scatter3(thrusterS_O(1), thrusterS_O(2), thrusterS_O(3), 100, 'm', 'filled', 'DisplayName', 'Thruster S');
hold off;
legend;

disp(thrusterP_O)
disp(thrusterQ_O)
disp(thrusterR_O)
disp(thrusterS_O)
