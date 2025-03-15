clc; close all;

figure;
subplot(3,1,1);
plot(out.tout, out.state_variables.Data(1,:))
title("X")
subplot(3,1,2);
plot(out.tout,out.state_variables.Data(2,:))
title("Y")
subplot(3,1,3);
plot(out.tout,out.state_variables.Data(3,:))
title("Z")

figure;
subplot(3,1,1);
plot(out.tout,out.state_variables.Data(4,:))
title("Roll")
subplot(3,1,2);
plot(out.tout,out.state_variables.Data(5,:))
title("Pitch")
subplot(3,1,3);
plot(out.tout,out.state_variables.Data(6,:))
title("Yaw")

figure;
subplot(3,1,1);
plot(out.tout,out.state_variables.Data(7,:))
title("X rate")
subplot(3,1,2);
plot(out.tout,out.state_variables.Data(8,:))
title("Y rate")
subplot(3,1,3);
plot(out.tout,out.state_variables.Data(9,:))
title("Z rate")

figure;
subplot(3,1,1);
plot(out.tout,out.state_variables.Data(10,:))
title("Roll rate")
subplot(3,1,2);
plot(out.tout,out.state_variables.Data(11,:))
title("Pitch rate")
subplot(3,1,3);
plot(out.tout,out.state_variables.Data(12,:))
title("Yaw rate")

%% Moments

% Bouyant
figure;
subplot(3,1,1);
plot(out.tout,out.moment_bus.buoyant.Data(1,:))
title("Moment: Bouyant x")
subplot(3,1,2);
plot(out.tout,out.moment_bus.buoyant.Data(2,:))
title("Moment: Bouyant y")
subplot(3,1,3);
plot(out.tout,out.moment_bus.buoyant.Data(3,:))
title("Moment: Bouyant z")

% Aero
figure;
subplot(3,1,1);
plot(out.tout,out.moment_bus.aero.Data(1,:))
title("Moment: Aero x")
subplot(3,1,2);
plot(out.tout,out.moment_bus.aero.Data(2,:))
title("Moment: Aero y")
subplot(3,1,3);
plot(out.tout,out.moment_bus.aero.Data(3,:))
title("Moment: Aero z")

% thruster
figure;
subplot(3,1,1);
plot(out.tout,out.moment_bus.thruster.Data(1,:))
title("Moment: thruster x")
subplot(3,1,2);
plot(out.tout,out.moment_bus.thruster.Data(2,:))
title("Moment: thruster y")
subplot(3,1,3);
plot(out.tout,out.moment_bus.thruster.Data(3,:))
title("Moment: thruster z")

%% Forces

% Bouyant
figure;
subplot(3,1,1);
plot(out.tout,out.force_bus.buoyant.Data(1,:))
title("Forces: Bouyant x")
subplot(3,1,2);
plot(out.tout,out.force_bus.buoyant.Data(2,:))
title("Forces: Bouyant y")
subplot(3,1,3);
plot(out.tout,out.force_bus.buoyant.Data(3,:))
title("Forces: Bouyant z")

% Aero
figure;
subplot(3,1,1);
plot(out.tout,out.force_bus.aero.Data(1,:))
title("Forces: Aero x")
subplot(3,1,2);
plot(out.tout,out.force_bus.aero.Data(2,:))
title("Forces: Aero y")
subplot(3,1,3);
plot(out.tout,out.force_bus.aero.Data(3,:))
title("Forces: Aero z")

% thruster
figure;
subplot(3,1,1);
plot(out.tout,out.force_bus.thruster.Data(1,:))
title("Forces: thruster x")
subplot(3,1,2);
plot(out.tout,out.force_bus.thruster.Data(2,:))
title("Forces: thruster y")
subplot(3,1,3);
plot(out.tout,out.force_bus.thruster.Data(3,:))
title("Forces: thruster z")