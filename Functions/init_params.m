function param = init_params()
    
    param.m = 0.148; % Mass of Blimp in kg

    %Blimp Geometry Param
    param.geometry = struct();
    param.geometry.I = 0.1*eye(3);
    param.geometry.vol_disp = 0.11446249033256; % m^3 right now just made this up for neutral weight
    param.geometry.HB_COB = [ eye(3) [0;0;0.3];
                               0 0 0 1];

    % Physical Constants
    param.physical = struct();
    param.physical.g = 9.80665; % m/s^2
    param.physical.rho = 1.293; % kg/m^3

    %Aerodynamic Constants
    param.aero = struct();

    param.aero.A = 0.23574480274;

    param.aero.C0D = 0.243;
    param.aero.C0S = 0.001;
    param.aero.C0L = 0.159;
    param.aero.C0M1 = 0.001;
    param.aero.C0M2 = 0.057;
    param.aero.C0M3 = 0.001;

    param.aero.CalphaD = 4.419;
    param.aero.CalphaS = -0.074;
    param.aero.CalphaL = 2.938;
    param.aero.CalphaM1 = -0.030;
    param.aero.CalphaM2 = 0.093;
    param.aero.CalphaM3 = -0.001;

    param.aero.CbetaD = 7.508;
    param.aero.CbetaS = -2.113;
    param.aero.CbetaL = 4.554;
    param.aero.CbetaM1 = -0.526;
    param.aero.CbetaM2 = 5.236;
    param.aero.CbetaM3 = -0.093;

    param.aero.K1 = -0.050;
    param.aero.K2 = -0.026;
    param.aero.K3 = -0.014;
    
    % Thruster Mapping wrt Body Fixed Frame (COM)
    param.thruster = struct();
    Op = [-0.0499; 0.0405; -0.0216];
    Oq = [-0.0499; 0.0395; -0.0216];
    Or = [-0.0499; 0.0244; -0.0201];
    Os = [-0.0449; 0.0234; -0.0201];

    RCOM_PQ = [0 0 -1;
               0 1 0;
               1 0 0];
    
    param.thruster.Hp = [RCOM_PQ Op;
                         0 0 0 1]; % X left view from back
    param.thruster.Hq = [RCOM_PQ Oq;
                         0 0 0 1]; % X right view from back
    param.thruster.Hr = [eye(3) Or;
                         0 0 0 1]; % Z left view from back
    param.thruster.Hs = [eye(3) Os;
                         0 0 0 1]; % Z right view from back

end