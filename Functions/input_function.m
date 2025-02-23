%% Define Input Function
% This function will be used to compute input at any time t
function u = input_function(t)
    u = struct();
    u.thruster = struct();  

    u.thruster.p = 0;
    u.thruster.q = 0;
    u.thruster.r = 10;
    u.thruster.s = 10;
end