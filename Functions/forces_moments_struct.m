function [Forces, Moments] = forces_moments_struct()
    Forces = struct();
    Forces.thruster = zeros([3,1]);
    Forces.aero = zeros([3,1]);
    Forces.gravity = zeros([3,1]);
    Forces.buoyant = zeros([3,1]);
    Forces.ground = zeros([3,1]);
    Forces.net = zeros([3,1]);
    
    Moments = struct();
    Moments.thruster = zeros([3,1]);
    Moments.aero = zeros([3,1]);
    Moments.buoyant = zeros([3,1]);
    Moments.net = zeros([3,1]);

end