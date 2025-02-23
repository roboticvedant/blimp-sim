%% State Space Functions
% Main state equations for ode45
function dxdt = state_equations(t, x)

    global param
    dxdt = zeros(12, 1);
    % Get input at current time
    u = input_function(t);
    param.geometry.T = [cos(x(6))*cos(x(5)) -sin(x(6)) 0;
                        sin(x(6))*cos(x(5)) cos(x(6)) 0;
                        -sin(x(5)) 0 1];
    param.geometry.R0B = [cos(x(5))*cos(x(6)) cos(x(6))*sin(x(4))*sin(x(5))-cos(x(4))*sin(x(6)) cos(x(4))*cos(x(6))*sin(x(5))+sin(x(4))*sin(x(6));
                         cos(x(5))*sin(x(6)) cos(x(4))*cos(x(6))-sin(x(4))*sin(x(5))*sin(x(6)) cos(x(4))*sin(x(5))*sin(x(6))-sin(x(4))*sin(x(6));
                         -sin(x(5)) cos(x(5))*sin(x(4)) cos(x(1))*cos(x(5))];

    Fth_P = param.thruster.Hp(1:3,1:3)*[0; 0; u.thruster.p];
    Fth_Q = param.thruster.Hq(1:3,1:3)*[0; 0; u.thruster.q];
    Fth_R = param.thruster.Hr(1:3,1:3)*[0; 0; u.thruster.r];
    Fth_S = param.thruster.Hs(1:3,1:3)*[0; 0; u.thruster.s];

    Fthruster = Fth_P + Fth_Q + Fth_R + Fth_S;

    Fgravity = param.geometry.R0B * [0; 0; -param.m*param.physical.g];

    Fboyant = param.geometry.R0B * [0; 0; param.physical.rho*param.geometry.vol_disp*param.physical.g];
    
    Mthruster = cross(param.thruster.Hp(1:3,4), Fth_P) ...
        + cross(param.thruster.Hq(1:3,4), Fth_Q) ...
        + cross(param.thruster.Hr(1:3,4), Fth_R) ...
        + cross(param.thruster.Hs(1:3,4), Fth_S);

    Mboyant = cross(param.geometry.HB_COB(1:3,4), Fboyant);


    Fb_xu = Fthruster + Fgravity + Fboyant;
    Mb_xu = Mboyant + Mthruster;
    
    % x y z
    dxdt(1:3) = param.geometry.R0B*x(7:9);
    
    % roll pitch yaw
    dxdt(4:6) = (param.geometry.T^(-1))*param.geometry.R0B*x(10:12);

    %velocity u v w
    dxdt(7:9) = (1/param.m)*(Fb_xu - param.m*(cross(x(10:12),x(7:9))));

    %velocity roll pitch yaw rates
    dxdt(10:12) = (param.geometry.I^(-1))*(Mb_xu - cross(x(10:12),(param.geometry.I*x(10:12))));
end