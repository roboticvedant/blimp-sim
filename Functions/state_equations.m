%% State Space Functions
% Main state equations for ode45
function dxdt = state_equations(t, x)

    global param
    global debug;

    dxdt = zeros(12, 1);
    % Get input at current time
    u = input_function(t);
    param.geometry.T = [cos(x(6))*cos(x(5)) -sin(x(6)) 0;
                        sin(x(6))*cos(x(5)) cos(x(6)) 0;
                        -sin(x(5)) 0 1];
    param.geometry.T = param.geometry.T + 1e-10*eye(size(param.geometry.T));

    param.geometry.R0B = [cos(x(6)) -sin(x(6)) 0;
        sin(x(6)) cos(x(6)) 0;
        0 0 1] * ...
        [cos(x(5)) 0 sin(x(5));
         0 1 0;
        -sin(x(5)) 0 cos(x(5))] * ...
        [1 0 0;
        0 cos(x(4)) -sin(x(4));
        0 sin(x(4)) cos(x(4))];

    param.geometry.R0B = param.geometry.R0B + 1e-10*eye(size(param.geometry.R0B));

    [U, ~, V] = svd(param.geometry.R0B); % Singular Value Decomposition
    param.geometry.R0B = U * V';  % Ensure R is a valid rotation matrix

    [U, ~, V] = svd(param.geometry.T); % Singular Value Decomposition
    param.geometry.T = U * V';  % Ensure T is a valid rotation matrix
   
    param.aero.v2 = norm(x(7:9))^2;
    if param.aero.v2 <= 1e-6
        Faero = zeros(3,1);
       if norm(x(10:12)) > 1e-6
            Cdamping = diag([param.aero.K1, param.aero.K2, param.aero.K3]);
            Maero = Cdamping * x(10:12);
        else
            Maero = zeros(3,1);
       end  
    else
        Rbb = [1 0 0; 0 -1 0; 0 0 -1];
        velA = Rbb*x(7:9);
        ua = velA(1);
        va = velA(2);
        wa = velA(3);
        V = norm(velA);
        attack_angle = atan(wa/ua);
        sideslip_angle = asin(va/V);
    
    param.geometry.RBV = [[cos(attack_angle)*cos(sideslip_angle), -cos(attack_angle)*sin(sideslip_angle),  -sin(attack_angle)]
                          [sin(sideslip_angle),  cos(sideslip_angle), 0]
                          [sin(attack_angle)*cos(sideslip_angle), -sin(attack_angle)*sin(sideslip_angle), cos(attack_angle)]];
    
    Cd = param.aero.C0D + param.aero.CalphaD*attack_angle^2 + param.aero.CbetaD*sideslip_angle^2;
    Cs = param.aero.C0S + param.aero.CalphaS*attack_angle^2 + param.aero.CbetaS*sideslip_angle;
    Cl = param.aero.C0L + param.aero.CalphaL*attack_angle + param.aero.CbetaL*sideslip_angle^2;

    Cm1 = param.aero.C0M1 + param.aero.CalphaM1*attack_angle + param.aero.CbetaM1*sideslip_angle;
    Cm2 = param.aero.C0M2 + param.aero.CalphaM2*attack_angle + param.aero.CbetaM2*sideslip_angle^4;
    Cm3 = param.aero.C0M3 + param.aero.CalphaM3*attack_angle + param.aero.CbetaM3*sideslip_angle;
    
    
    D = (0.5)*param.physical.rho*param.aero.v2*param.aero.A*Cd;
    S = (0.5)*param.physical.rho*param.aero.v2*param.aero.A*Cs;
    L = (0.5)*param.physical.rho*param.aero.v2*param.aero.A*Cl;

    M1 = (0.5)*param.physical.rho*param.aero.v2*param.aero.A*Cm1 + param.aero.K1*x(10);
    M2 = (0.5)*param.physical.rho*param.aero.v2*param.aero.A*Cm2 + param.aero.K2*x(11);
    M3 = (0.5)*param.physical.rho*param.aero.v2*param.aero.A*Cm3 + param.aero.K3*x(12);
    Faero = Rbb*param.geometry.RBV * [-D; S; -L];

    Maero = Rbb*param.geometry.RBV * [M1; M2; M3];
    end

    Fth_P = param.thruster.Hp(1:3,1:3)*[0; 0; u.thruster.p];
    Fth_Q = param.thruster.Hq(1:3,1:3)*[0; 0; u.thruster.q];
    Fth_R = param.thruster.Hr(1:3,1:3)*[0; 0; u.thruster.r];
    Fth_S = param.thruster.Hs(1:3,1:3)*[0; 0; u.thruster.s];

    Fthruster = Fth_P + Fth_Q + Fth_R + Fth_S;

    Fgravity = param.geometry.R0B' * [0; 0; -param.m*param.physical.g];

    Fboyant = param.geometry.R0B' * [0; 0; param.physical.rho*param.geometry.vol_disp*param.physical.g];
    
    Mthruster = cross(param.thruster.Hp(1:3,4), Fth_P) ...
        + cross(param.thruster.Hq(1:3,4), Fth_Q) ...
        + cross(param.thruster.Hr(1:3,4), Fth_R) ...
        + cross(param.thruster.Hs(1:3,4), Fth_S);

    Mboyant = cross(param.geometry.HB_COB(1:3,4), Fboyant);

    Fground = zeros(3, 1);
    % Mground = zeros(3, 1);
    % Define ground parameters
    ground_height = 0; % Set this to  desired ground height
     
    % Check if vehicle is at or below ground level
    if x(3) <= ground_height
        disp("Collision with Ground !!")
        % disp(t)
        % disp(x)
        Fnet_body = Fthruster + Fgravity + Fboyant + Faero;
        Fnet_world = param.geometry.R0B * Fnet_body;
    
        if Fnet_world(3) < 0
            Fground = param.geometry.R0B' * [0; 0; -Fnet_world(3)];
        end
    end

    Fb_xu = Fthruster + Fgravity + Fboyant + Faero + Fground ;
    Mb_xu = Mboyant + Mthruster + Maero ;
    
    % Store velocity squared for debugging
    debug.v2 = [debug.v2; param.aero.v2];
    
    % Store forces and moments in structured form
    debug.Fb_xu = [debug.Fb_xu, Fb_xu]; % Net body force (3xN)
    debug.Fthruster = [debug.Fthruster, Fthruster]; % Thruster force (3xN)
    debug.Fgravity = [debug.Fgravity, Fgravity]; % Gravity force (3xN)
    debug.Fboyant = [debug.Fboyant, Fboyant]; % Buoyant force (3xN)
    debug.Faero = [debug.Faero, Faero]; % Aerodynamic force (3xN)
    
    debug.Mb_xu = [debug.Mb_xu, Mb_xu]; % Net moment (3xN)
    debug.Mthruster = [debug.Mthruster, Mthruster]; % Thruster moment (3xN)
    debug.Maero = [debug.Maero, Maero]; % Aerodynamic moment (3xN)
    % debug.attack_angle = [debug.attack_angle, attack_angle];
    % debug.sideslip_angle = [debug.sideslip_angle, sideslip_angle]; 
    % 
    % debug.Cd = [debug.Cd, Cd];
    % debug.Cs = [debug.Cs, Cs];
    % debug.Cl = [debug.Cl, Cl];
    % debug.Cm1 = [debug.Cm1, Cm1];
    % debug.Cm2= [debug.Cm2, Cm2];
    % debug.Cm3 = [debug.Cm3, Cm3];
    % 
    % debug.D = [debug.D, D];
    % debug.S=  [debug.S, S];
    % debug.L = [debug.L, L];
    % debug.M1 = [debug.M1, M1];
    % debug.M2=  [debug.M2, M2];
    % debug.M3 = [debug.M3, M3];

    
    % x y z
    dxdt(1:3) = param.geometry.R0B*x(7:9);
    
    % roll pitch yaw
    dxdt(4:6) = (param.geometry.T^(-1))*param.geometry.R0B*x(10:12);

    %velocity u v w
    dxdt(7:9) = (1/param.m)*(Fb_xu - param.m*(cross(x(10:12),x(7:9))));

    %velocity roll pitch yaw rates
    dxdt(10:12) = (param.geometry.I^(-1))*(Mb_xu - cross(x(10:12),(param.geometry.I*x(10:12))));
end