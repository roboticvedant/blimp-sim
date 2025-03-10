%% Define Input Function
% This function will be used to compute input at any time t
function u = input_function(t)
    u = struct();
    u.thruster = struct();  

    u.thruster.p = -0.0001*(1-heaviside(t-000));
    u.thruster.q = -0.000*(1-heaviside(t-000));
    u.thruster.r = 0.0015*(1-heaviside(t-1000));
    u.thruster.s = 0.0015*(1-heaviside(t-1000));
end